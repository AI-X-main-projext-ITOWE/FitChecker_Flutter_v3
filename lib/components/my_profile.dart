import 'package:fitchecker/components/edit_profile.dart';
import 'package:fitchecker/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String _name = ""; // 사용자 이름

  Map<String, List<Map<String, dynamic>>> _exerciseData = {}; // 날짜별 운동 데이터
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // 사용자 정보 가져오기
    _fetchExerciseData(); // 모든 운동 기록 가져오기
  }

  // Firestore에서 사용자 정보 가져오기
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            _name = snapshot['name'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Firestore에서 운동 기록 가져오기
  Future<void> _fetchExerciseData() async {
    final user = FirebaseAuth.instance.currentUser;
    final year = DateTime.now().year.toString();
    final month = DateTime.now().month.toString().padLeft(2, '0');
    final today = '${year}-${month}';

    if (user != null) {
      final uid = user.uid;

      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('exercise_days')
            .orderBy('exerciseDate')
            .get();

        final Map<String, List<Map<String, dynamic>>> exerciseData = {};

        // querySnapshot으로 가져온 각 문서 처리
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final docDate = data['exerciseDate']; // "2024-12-10" 형태라고 가정

          if (docDate != null && docDate is String && docDate.isNotEmpty) {
            // 날짜별로 exerciseData에 쌓기
            exerciseData.putIfAbsent(docDate, () => []);
            exerciseData[docDate]!.add({
              "exerciseName": data['exerciseName'] ?? "",
              "totalCounter": data['totalCounter'] ?? 0,
              "exerciseTime": data['exerciseTime'] ?? 0,
            });
          }
        }

        setState(() {
          _exerciseData = exerciseData;
        });

        print("All Exercise Data Loaded: $_exerciseData");
      } catch (e) {
        print('Error fetching exercise data: $e');
      }
    }
  }

  // 운동 기록 팝업 표시
  void _showExercisesPopup(DateTime date) {
    String formattedDate = _formatDate(date);

    // _exerciseData에서 데이터 조회
    List<Map<String, dynamic>> exercises = _exerciseData[formattedDate] ?? [];

    if (exercises.isEmpty) {
      _showTopMessage("운동 기록이 없습니다.");
      return;
    }

    // 나머지 코드는 그대로 유지
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // 전체 소모 칼로리 계산
        double totalCalories = exercises.fold(0, (sum, exercise) {
          double caloriesPerMinute = 0;

          switch (exercise['exerciseName']) {
            case 'push-up':
              caloriesPerMinute = 3.5;
              break;
            case 'pull-up':
              caloriesPerMinute = 4.0;
              break;
            case 'squat':
              caloriesPerMinute = 5.0;
              break;
            case 'sit-up':
              caloriesPerMinute = 3.0;
              break;
          }

          int timeInSeconds = int.tryParse(exercise['exerciseTime']) ?? 0;

          return sum + (caloriesPerMinute * (timeInSeconds / 60));
        });

        return Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 소모 칼로리 창 (X 버튼 포함)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C2FF2),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "소모 칼로리 : ${totalCalories.toStringAsFixed(1)} kcal",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      String translatedName = '';
                      switch (exercise['exerciseName']) {
                        case 'push-up':
                          translatedName = '푸쉬 업';
                          break;
                        case 'pull-up':
                          translatedName = '풀 업';
                          break;
                        case 'squat':
                          translatedName = '스쿼트';
                          break;
                        case 'sit-up':
                          translatedName = '싯 업';
                          break;
                      }

                      int timeInSeconds = int.tryParse(exercise['exerciseTime']) ?? 0;
                      int minutes = (timeInSeconds / 60).floor();
                      int seconds = timeInSeconds % 60;

                      String timeDisplay = minutes > 0
                          ? "$minutes분 ${seconds}초"
                          : "${seconds}초";

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15.0),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translatedName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6C2FF2),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    timeDisplay,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${exercise['totalCounter']} 회",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

// 상단바 메시지 표시
  void _showTopMessage(String message) {
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          '내 정보', // 헤더 제목
          style: TextStyle(
            color: Colors.white, // 텍스트 색상 흰색
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // 제목을 가운데 정렬
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white, // 원하는 배경색
                  borderRadius: BorderRadius.circular(12), // 테두리를 둥글게 설정
                ),
                padding: const EdgeInsets.all(20.0), // 내부 여백
                child: Column(
                  children: [
                    // 사용자 이름 표시
                    Text(
                      '$_name 님', // Firebase에서 가져온 사용자 이름
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(), // 구분선
                    SizedBox(height: 16),
                    // 상세정보 보기 버튼
                    ElevatedButton(
                      onPressed: () async {
                        // EditProfile 화면을 열고 결과를 기다립니다.
                        final result = await Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => EditProfile(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0); // 시작 위치: 아래
                              const end = Offset.zero; // 끝 위치: 화면
                              const curve = Curves.easeInOut; // 애니메이션 곡선

                              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              final offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation, // 슬라이드 애니메이션
                                child: child,
                              );
                            },
                          ),
                        );

                        // 결과가 'updated'인 경우 데이터를 다시 불러옵니다.
                        if (result == 'updated') {
                          _fetchUserData();
                          _fetchExerciseData();
                        }
                      },
                      child: Text('프로필 수정'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C2FF2), // 보라색 배경
                        foregroundColor: Colors.white, // 흰색 글자
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 버튼 패딩
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        minimumSize: Size(double.infinity, 50), // 텍스트 스타일
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 캘린더 부분
            Padding(
              padding: const EdgeInsets.all(16.0), // 캘린더 주변 패딩
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white, // 원하는 배경색 설정
                  borderRadius: BorderRadius.circular(12), // 테두리 둥글게 설정
                ),
                child: TableCalendar(
                  focusedDay: _selectedDate,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarFormat: CalendarFormat.month, // 월 뷰로 고정
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // 뷰 전환 버튼 숨기기
                    titleCentered: true, // 제목 중앙 정렬
                    titleTextFormatter: (date, locale) {
                      // 날짜 형식 변경
                      return '${date.month}월, ${date.year}';
                    },
                    titleTextStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
                  ),
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  eventLoader: (day) {
                    String formattedDate = _formatDate(day);

                    if (_exerciseData.containsKey(formattedDate) &&
                        _exerciseData[formattedDate]!.isNotEmpty) {
                      return [true]; // 이벤트가 있으면 마커를 표시
                    } else {
                      return [];
                    }
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });

                    _showExercisesPopup(selectedDay); // 선택된 날짜의 팝업 표시
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        // 이벤트가 있는 날짜에만 마커 표시
                        return Positioned(
                          bottom: 5, // 마커 위치
                          child: Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: Colors.red[900], // 마커 색상
                              shape: BoxShape.circle, // 마커 모양
                            ),
                          ),
                        );
                      }
                      return null; // 이벤트가 없으면 마커 표시하지 않음
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    markersAutoAligned: false, // 마커 위치를 수동으로 조정
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // 구분선 추가
            Divider(thickness: 2.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0); // 아래에서 올라오는 애니메이션
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        final offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                icon: Icon(Icons.settings, color: Colors.white),
                label: Text("설정", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C2FF2),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
