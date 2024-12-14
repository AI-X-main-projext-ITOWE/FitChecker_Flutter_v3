import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // flutter_markdown 추가

class Chatbot extends StatefulWidget {
  final String initialMessage; // 추가된 메시지

  Chatbot({required this.initialMessage});

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // 메시지 리스트
  bool _isWaitingForResponse = false; // 응답 대기 상태
  String _userId = "";
  int _userAge = 0;
  double _userHeight = 0;
  double _userWeight = 0;
  String _userGender = "";


  @override
  void initState() {
    super.initState();
    _fetchUserId(); // Firebase UID 가져오기
    _controller.text = widget.initialMessage;
    _sendMessage(); // 페이지 로딩 시 자동으로 메시지 전송
  }

  Future<void> _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if(snapshot.exists){
          _userId = user.uid;
          _userAge = int.parse(snapshot['age']);
          _userHeight = double.parse(snapshot['height']);
          _userWeight = double.parse(snapshot['weight']);
          _userGender = snapshot['gender'];
        }

      }  catch (e) {
        print('Error fetching user data: $e');
      }

      setState(() {
        _userId = user.uid;
      });
    }
  }

  // FastAPI 서버에 질문을 POST로 보내기
  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isWaitingForResponse) return;

    // 사용자 메시지를 채팅창에 추가
    setState(() {
      _messages.add({"sender": "user", "text": question});
      _isWaitingForResponse = true; // 응답 대기 상태 활성화
      _messages.add({"sender": "bot", "text": "AI 트레이너가 답변을 생성 중입니다."});
    });

    final url = Uri.parse('http://10.0.2.2:8000/api/v1/agent');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "request": {
            "user_id": _userId,
            "age": _userAge,
            "height": _userHeight,
            "weight": _userWeight,
            "gender": _userGender,
            "question": question,
          },
          "audio_bytes": "string"
        }),
      );

      if (response.statusCode == 200) {
        // JSON 응답 파싱
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        // response.advice_response.response에서 내용 가져오기
        final adviceResponse = responseData['response']?['advice_response']?['response'] ?? "응답을 처리할 수 없습니다.";

        setState(() {
          // "답변 생성 중" 메시지를 교체
          _messages.removeLast();
          _messages.add({"sender": "bot", "text": adviceResponse});
        });
      } else {
        setState(() {
          // "답변 생성 중" 메시지를 교체
          _messages.removeLast();
          _messages.add({"sender": "bot", "text": "Error: ${response.statusCode}"});
        });
      }
    } catch (e) {
      setState(() {
        // "답변 생성 중" 메시지를 교체
        _messages.removeLast();
        _messages.add({"sender": "bot", "text": "Error: $e"});
      });
    } finally {
      _controller.clear();
      setState(() {
        _isWaitingForResponse = false; // 응답 대기 상태 해제
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 채팅 메시지 표시 영역
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: isUser
                        ? Text(
                      message['text'] ?? "",
                      style: TextStyle(fontSize: 16),
                    )
                        : MarkdownBody(
                      data: message['text'] ?? "", // AI 응답을 Markdown 형식으로 표시
                      selectable: true, // 텍스트 선택 가능
                    ),
                  ),
                );
              },
            ),
          ),
          // 고정된 입력 필드와 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                // 질문 입력 필드
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'AI 트레이너에게 질문하세요.',
                    ),
                    enabled: !_isWaitingForResponse, // 응답 대기 중에는 입력 비활성화
                  ),
                ),
                SizedBox(width: 8),
                // 전송 버튼
                ElevatedButton(
                  onPressed: _isWaitingForResponse ? null : _sendMessage, // 응답 대기 중에는 버튼 비활성화
                  child: Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}