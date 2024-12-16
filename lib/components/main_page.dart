import 'package:fitchecker/components/choice_exercise.dart';
import 'package:fitchecker/components/exerciseGraph.dart';
import 'package:flutter/material.dart';
import 'chatbot.dart'; // Chatbot 페이지
import 'fcmalarm.dart';

class MainPage extends StatelessWidget {

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
              ExerciseGraph(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context) {
      double screenWidth = MediaQuery
          .of(context)
          .size
          .width; // 화면 너비

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: screenWidth * 0.9,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "● 운동 계획하기",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 4),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildExerciseCard(context, "assets/images/routine.png", "운동 시작", ChoiceExercise()),
                _buildExerciseCard(context, "assets/images/diet.png", "식단 짜기", Chatbot(initialMessage: '식단 짜줘',)),
                _buildExerciseCard(context, "assets/images/alarm.png", "운동 알림설정", AlarmListPage()),
                // _buildExerciseCard(context, "assets/images/chatbot.png", "챗봇", ChatbotPage()),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
  Widget _buildExerciseCard(BuildContext context, String imagePath, String title, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        // 카드 클릭 시 해당 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Container(
        width: 100,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}