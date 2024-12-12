import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import ' edit_profile.dart';

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
            .startAt([today])
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("운동 기록이 없습니다.")),
      );
      return;
    }

    // 팝업에 운동 기록 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView.builder(
                controller: scrollController,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    title: Text("운동 이름: ${exercise['exerciseName']}"),
                    subtitle: Text(
                      "총 횟수: ${exercise['totalCounter']}회\n"
                          "운동 시간: ${exercise['exerciseTime']}초",
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: () {
                        // Navigator로 화면 전환 (밑에서 위로 올라오는 애니메이션)
                        Navigator.of(context).push(
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
                      },
                      child: Text('프로필 수정'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기
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
          ],
        ),
      ),
    );
  }
}