import 'package:fitchecker/components/choice_exercise.dart';
import 'package:fitchecker/components/exerciseGraph.dart';
import 'package:flutter/material.dart';
import 'chatbot.dart'; // Chatbot 페이지
import 'fcmalarm.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // 배경색을 흰색으로 설정
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              _buildExerciseList(context), // 수정된 부분
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // 가로 크기 제한
                child: Divider(
                  color: Colors.grey, // Divider 색상
                  thickness: 1, // Divider 두께
                ),
              ),
              SizedBox(height: 20.0),
              ExerciseGraph(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: screenWidth * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8, // 너비를 화면 전체로
                  maxHeight: MediaQuery.of(context).size.height * 0.05, // 최소 높이 50
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF6C2FF2), // 박스 배경색 (보라색)
                  borderRadius: BorderRadius.circular(8), // 선택적으로 모서리를 둥글게
                ),
                alignment: Alignment.center, // 텍스트 중앙 정렬
                child: Text(
                  "● 운동 계획하기",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // 텍스트 색상 흰색
                    fontWeight: FontWeight.bold, // 텍스트 굵게
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등한 간격 배치
                children: [
                  _buildExerciseCard(context, "assets/images/routine.png", "운동 시작", ChoiceExercise()),
                  _buildExerciseCard(context, "assets/images/routine.png", "운동 설계", Chatbot(initialMessage: '내 신체 정보에 알맞는 운동 루틴 설계해 줘.')),
                  _buildExerciseCard(context, "assets/images/diet.png", "식단 짜기", Chatbot(initialMessage: '내 신체 정보에 알맞는 추천 식단 짜 줘.')),
                  _buildExerciseCard(context, "assets/images/alarm.png", "알람 확인", AlarmListPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, String imagePath, String title, Widget targetPage) {
    return Center( // 가로 중앙 정렬
      child: GestureDetector(
        onTap: () {
          // 카드 클릭 시 해당 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 30, // 이미지 크기
                  height: 30,
                  fit: BoxFit.cover,
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}