import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitchecker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitchecker/components/camera.dart';

class ChoiceExercise extends StatefulWidget {
  @override
  _ChoiceExerciseState createState() => _ChoiceExerciseState();
}

class _ChoiceExerciseState extends State<ChoiceExercise> {
  static const platform = MethodChannel('com.example.fitchecker/exercise'); // 채널 이름

  int _sets = 1;
  int _reps = 10;

  Future<void> _sendExerciseToNative(String exercise, int sets, int reps) async {
    try {
      await platform.invokeMethod('setExercise', {
        "exercise": exercise,
        "sets": sets,
        "reps": reps,
      });
      print("Exercise sent to Native: $exercise, Sets: $sets, Reps: $reps");

    } on PlatformException catch (e) {
      print("Failed to send exercise: ${e.message}");
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

  void _onMenuClick(String exercise) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5), // 뒷화면 흐리게
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "운동 설정",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context), // 팝업 닫기
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // 세트 설정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("세트 수:", style: TextStyle(fontSize: 16)), // 세트 수 텍스트
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove), // 감소 버튼
                            onPressed: () {
                              if (_sets > 1) {
                                setModalState(() {
                                  _sets--;
                                });
                              }
                            },
                          ),
                          Container(
                            width: 30, // 숫자의 고정 너비를 설정
                            alignment: Alignment.center, // 숫자를 중앙 정렬
                            child: Text(
                              "$_sets",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add), // 증가 버튼
                            onPressed: () {
                              setModalState(() {
                                _sets++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

// 횟수 설정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("세트당 횟수:", style: TextStyle(fontSize: 16)), // 세트당 횟수 텍스트
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove), // 감소 버튼
                            onPressed: () {
                              if (_reps > 1) {
                                setModalState(() {
                                  _reps--;
                                });
                              }
                            },
                          ),
                          Container(
                            width: 30, // 숫자의 고정 너비를 설정
                            alignment: Alignment.center, // 숫자를 중앙 정렬
                            child: Text(
                              "$_reps",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add), // 증가 버튼
                            onPressed: () {
                              setModalState(() {
                                _reps++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await _sendExerciseToNative(exercise, _sets, _reps); // 네이티브로 데이터 전송
                      print(exercise);
                      print(_sets);
                      print(_reps);
                      Navigator.pop(context); // 팝업 닫기
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Camera()), // 카메라로 이동
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "시작",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    final screenHeight = MediaQuery.of(context).size.height * (1 - 0.32);

    return Scaffold(
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
          'AI와 함께 운동하기', // 헤더 제목
          style: TextStyle(
            color: Colors.white, // 텍스트 색상 흰색
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // 제목을 가운데 정렬
      ),
      backgroundColor: Colors.grey[200], // 배경색 설정
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // 화면 크기에 비례한 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMenuItem('푸쉬업', 'assets/images/menu_pushup.jpg', () {
                _onMenuClick("push-up");
              }, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.012), // 화면 높이에 비례한 간격
              _buildMenuItem('풀업', 'assets/images/menu_pullup.jpg', () {
                _onMenuClick("pull-up");
              }, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.012),
              _buildMenuItem('스쿼트', 'assets/images/menu_squat.jpg', () {
                _onMenuClick("squat");
              }, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.012),
              _buildMenuItem('싯업', 'assets/images/menu_situp.jpg', () {
                _onMenuClick("sit-up");
              }, screenWidth, screenHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String imagePath, VoidCallback onTap, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.9, // 화면 너비의 90%
        height: screenHeight * 0.18, // 화면 높이에 비례한 높이 (여기서는 20%로 설정)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(imagePath), // 배경 이미지 설정
            fit: BoxFit.cover, // 이미지를 컨테이너에 맞춤
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.1), // 동적 여백
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.05, // 텍스트 크기 동적 설정
              fontWeight: FontWeight.bold,
              color: Colors.white, // 텍스트 색상을 흰색으로 설정
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0), // 텍스트 그림자
                  blurRadius: 3.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
