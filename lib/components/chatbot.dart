import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Chatbot extends StatefulWidget {
  final String initialMessage;

  Chatbot({required this.initialMessage});

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가
  bool _isWaitingForResponse = false;
  String _userId = "";
  int _userAge = 0;
  double _userHeight = 0;
  double _userWeight = 0;
  String _userGender = "";

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _messages.add({"sender": "bot", "text": "AI 트레이너에게 운동에 관하여,  \n무엇이든 물어보세요!  \n  \nex)  \n오전 7시에 풀업 10회 씩 3세트 알람 맞춰 줘.  \n 기초 체력을 기를 수 있는 운동 추천해 줘."});
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

        if (snapshot.exists) {
          _userId = user.uid;
          _userAge = int.parse(snapshot['age']);
          _userHeight = double.parse(snapshot['height']);
          _userWeight = double.parse(snapshot['weight']);
          _userGender = snapshot['gender'];
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isWaitingForResponse) return;

    setState(() {
      _messages.add({"sender": "user", "text": question});
      _isWaitingForResponse = true;
      _messages.add({"sender": "bot", "text": "AI 트레이너가 답변을 생성 중입니다.  \n잠시만 기다려주세요."});
    });

    _scrollToBottom(); // 메시지 추가 후 스크롤 이동

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
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if(responseData['response']?['counter_response'] != null){
          final counterResponse = responseData['response']?['counter_response']?['response'] ?? "응답을 처리할 수 없습니다.";

          setState(() {
            _messages.removeLast();
            _messages.add({"sender": "bot", "text": counterResponse});
          });
        }

        if(responseData['response']?['advice_response'] != null){
          final adviceResponse = responseData['response']?['advice_response']?['response'] ?? "응답을 처리할 수 없습니다.";

          setState(() {
            _messages.removeLast();
            _messages.add({"sender": "bot", "text": adviceResponse});
          });
        }

        if(responseData['response']?['alarm_response'] != null){
          final alarmResponse = responseData['response']?['alarm_response']?['response'] ?? "응답을 처리할 수 없습니다.";

          setState(() {
            _messages.removeLast();
            _messages.add({"sender": "bot", "text": alarmResponse});
          });
        }


      } else {
        setState(() {
          _messages.removeLast();
          _messages.add({"sender": "bot", "text": "Error: ${response.statusCode}"});
        });
      }
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({"sender": "bot", "text": "Error: $e"});
      });
    } finally {
      _controller.clear();
      setState(() {
        _isWaitingForResponse = false;
      });
      _scrollToBottom(); // 응답 이후 스크롤 이동
    }
  }

  // 스크롤을 최하단으로 이동시키는 함수
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면을 누르면 가상 키보드 닫기
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // 헤더 추가
        appBar: AppBar(
          backgroundColor: Color(0xFF6C2FF2), // 헤더 배경색 보라색
          elevation: 0, // 그림자 제거
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // 뒤로가기 버튼
            onPressed: () {
              Navigator.of(context).pop(); // 이전 화면으로 이동
            },
          ),
          title: Text(
            'AI 트레이너와 대화', // 헤더 제목
            style: TextStyle(
              color: Colors.white, // 텍스트 색상 흰색
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true, // 제목을 가운데 정렬
        ),
        body: Column(
          children: [
            // 채팅 메시지 표시 영역
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // 스크롤 컨트롤러 연결
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == "user";

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomPaint(
                        painter: MessageBubblePainter(isUser: isUser), // 말풍선 꼬리 유지
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? Color(0xFF6C2FF2) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: isUser
                              ? Text(
                            message['text'] ?? "",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )
                              : MarkdownBody(
                            data: message['text'] ?? "",
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 입력 필드와 전송 버튼
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '질문 입력하기',
                        labelStyle: TextStyle(color: Color(0xFF6C2FF2)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6C2FF2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6C2FF2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6C2FF2), width: 2.0),
                        ),
                      ),
                      enabled: !_isWaitingForResponse,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (!_isWaitingForResponse) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isWaitingForResponse ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C2FF2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text('전송'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 말풍선 꼬리 그림
class MessageBubblePainter extends CustomPainter {
  final bool isUser;

  MessageBubblePainter({required this.isUser});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isUser ? Color(0xFF6C2FF2) : Colors.grey[200]!
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isUser) {
      // 오른쪽 말풍선
      path.moveTo(size.width, size.height * 0.5);
      path.lineTo(size.width + 10, size.height * 0.4);
      path.lineTo(size.width, size.height * 0.3);
    } else {
      // 왼쪽 말풍선
      path.moveTo(0, size.height * 0.5);
      path.lineTo(-10, size.height * 0.4);
      path.lineTo(0, size.height * 0.3);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}