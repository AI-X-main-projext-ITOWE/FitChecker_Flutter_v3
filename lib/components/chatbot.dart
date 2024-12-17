import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'camera.dart';

class Chatbot extends StatefulWidget {
  final String initialMessage;

  Chatbot({required this.initialMessage});

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  static const platform = MethodChannel('com.example.fitchecker/exercise');

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가
  bool _isWaitingForResponse = false;
  String _userId = "";
  String _fcmToken = "";
  int _userAge = 0;
  double _userHeight = 0;
  double _userWeight = 0;
  String _userGender = "";
  final String apiUrl = dotenv.env['API_BASE_URL'] ?? "http://default.com/";



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

        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (snapshot.exists) {
          _userId = user.uid;
          _fcmToken = fcmToken!;
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

    final url = Uri.parse('${apiUrl}/api/v1/agent');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "request": {
            "user_id": _userId,
            "fcm_token": _fcmToken,
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
          // counter_response를 Map<String, dynamic>으로 타입 변환
          final counterResponse = responseData['response']?['counter_response'] as Map<String, dynamic>;

          // 각 필드를 안전하게 파싱
          final exercise = counterResponse['exercise']?.toString() ?? "unknown"; // 운동 이름
          final sets = counterResponse['exercise_set'] is int
              ? counterResponse['exercise_set'] as int
              : int.tryParse(counterResponse['exercise_set']?.toString() ?? "1") ?? 1;
          final reps = counterResponse['exercise_counter'] is int
              ? counterResponse['exercise_counter'] as int
              : int.tryParse(counterResponse['exercise_counter']?.toString() ?? "1") ?? 1;
          final responseText = counterResponse['response']?.toString() ?? "응답을 처리할 수 없습니다.";

          // 네이티브로 데이터 전달 후 카메라 실행
          await _startNativeCamera(exercise, sets, reps);

          // UI 업데이트
          setState(() {
            _messages.removeLast(); // "AI 트레이너가 답변을 생성 중입니다." 메시지 삭제
            _messages.add({"sender": "bot", "text": responseText});
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

  Future<void> _startNativeCamera(String exercise, int sets, int reps) async {
    try {
      await platform.invokeMethod('setExercise', {
        "exercise": exercise,
        "sets": sets,
        "reps": reps,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Camera(),
        ),
      );
    } on PlatformException catch (e) {
      print("Failed to start camera: ${e.message}");
    } finally {
      listenToNative();
    }
  }

  static void listenToNative() {

    platform.setMethodCallHandler((call) async {
      if (call.method == 'sendExerciseInfo') {
        Map<String, dynamic> data = Map<String, dynamic>.from(call.arguments);
        String exercise = data['exercise'];
        int totalCounter = data['totalCounter'];
        int exerciseTime = data['exerciseTime'];
        String exerciseDay = data['exerciseDay'];

        print('Exercise: $exercise');
        print('Total Counter: $totalCounter');
        print('Exercise Time: $exerciseTime');
        print('Exercise Day: $exerciseDay');
        // 데이터를 UI에 반영하거나 처리

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final uid = user.uid; // 사용자 UID

          // 날짜와 시간 분리
          final dateParts = exerciseDay.split(' '); // "2024-12-6 12:4:32"
          final date = dateParts[0]; // "2024-12-6" (날짜 부분)
          final time = dateParts[1]; // "12:4:32" (시간 부분)

          // 날짜를 "YYYY-MM-DD" 형식으로 포맷
          final formattedDateParts = date.split('-');
          final formattedDate = "${formattedDateParts[0]}-${formattedDateParts[1].padLeft(2, '0')}-${formattedDateParts[2].padLeft(2, '0')}";

          // Firestore 경로 설정
          final dayDocRef = FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('exercise_days')
              .doc("exercise_${formattedDate}_${exercise}");

          // final exerciseDocRef = dayDocRef.collection('exercise_types').doc("exercise_${exercise}");

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            // 운동 날짜 문서 업데이트
            final daySnapshot = await transaction.get(dayDocRef);
            if (daySnapshot.exists) {
              final existingData = daySnapshot.data()!;
              final updatedTotalCounter =
              (int.parse(existingData['totalCounter'] ?? '0') + totalCounter).toString();
              final updatedExerciseTime =
              (int.parse(existingData['exerciseTime'] ?? '0') + exerciseTime).toString();

              transaction.update(dayDocRef, {
                'totalCounter': updatedTotalCounter,
                'exerciseTime': updatedExerciseTime,
              });
            } else {
              transaction.set(dayDocRef, {
                'totalCounter': totalCounter.toString(),
                'exerciseTime': exerciseTime.toString(),
                'exerciseDate': formattedDate.toString(),
                'exerciseName': exercise.toString()
              });
            }
          });
        } else {
          print('사용자가 로그인하지 않았습니다.');
        }
      }
    });
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
              Navigator.pop(context); // 이전 화면으로 이동
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