import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            // 앱 이름과 버전
            Text(
              '앱 이름: FitChecker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('버전: 1.0.0', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // 출처 정보
            Text(
              '출처 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '- 이 앱은 사용자 정보를 기반으로 LLM Agent를 이용하여 개인 맞춤형 운동과 식단을 추천합니다.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '- 사용자가 운동할 때 자세가 잘못되었을 경우, AI가 바른 자세로 교정하도록 도와줍니다.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '- 개인 알림 설정을 통해 원하는 시간에 운동 알람을 받을 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // 오픈소스 라이브러리
            Text(
              '오픈소스 라이브러리',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '- GPT-04-Mini: 개인 맞춤형 운동과 식단 추천.\n'
                  '- Hugging Face: LLM 모델 및 자연어 처리 지원.\n'
                  '- cloud_firestore: Firebase 기반 데이터 관리.\n'
                  '- intl: 날짜 및 시간 처리를 위한 패키지.\n'
                  '- flutter_swiper: 앱 내 슬라이더 UI 구현.\n'
                  '- fastapi: AI 모델과의 통신을 위한 백엔드 프레임워크.\n'
                  '- uvicorn: ASGI 서버 실행을 위한 Python 서버.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // 개발자 정보
            Text(
              '개발자 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '개발자 팀: ITOWE\n'
                  '구성원: 5명\n'
                  '이메일: itowe4321@gmail.com\n'
                  '웹사이트: https://github.com/AI-X-main-projext-ITOWE\n'
                  '설명: ITOWE 팀은 건강과 운동을 위한 혁신적인 앱을 목표로 합니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // 저작권
            Text(
              '저작권',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Copyright 2024, ITOWE Team. All Rights Reserved.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
