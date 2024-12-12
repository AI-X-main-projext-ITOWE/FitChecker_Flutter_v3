import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chatbot.dart'; // Chatbot 페이지
import 'fcmalarm.dart';

class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            // Swiper
            _buildSwiper(context),
            SizedBox(height: 20.0),
            // 두 번째 메뉴
            _buildExerciseList(context), // 수정된 부분
          ],
        ),
      ),
    );
  }

  Widget _buildSwiper(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenWidth = MediaQuery
            .of(context)
            .size
            .width; // 화면 너비


        return ClipRRect(
          borderRadius: BorderRadius.circular(30.0), // 모서리를 둥글게 설정
          child: Container(
            width: screenWidth * 0.9, // 화면 너비의 90%
            height: screenWidth * 0.9, // 화면 너비의 40%
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                final imagePaths = [
                  'assets/images/test_banner01.png',
                  'assets/images/test_banner02.png',
                  'assets/images/test_banner03.png',
                ];

                final urls = [
                  'https://www.myprotein.co.kr/referrals.list?applyCode=JRHK-RL',
                  null, // 두 번째 배너는 동작 없음
                  null, // 세 번째 배너는 동작 없음
                ];

                return GestureDetector(
                  onTap: () {
                    if (urls[index] != null) {
                      _launchURL(urls[index]!);
                    }
                  },
                  child: Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
              itemCount: 3,
              // 슬라이드 갯수
              autoplay: true,
              pagination: SwiperPagination(),
              // 페이지네이션
              control: SwiperControl(), // 슬라이더 컨트롤
            ),
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('URL launched successfully: $url');
      } else {
        print('Cannot launch URL: $url');
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Widget _buildExerciseList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "운동 계획하기",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 10),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // _buildExerciseCard(context, "assets/images/routine.png", "운동 루틴", ExerciseRoutinePage()),
                _buildExerciseCard(context, "assets/images/diet.png", "식단 짜기", Chatbot(initialMessage: '식단짜줘',)),
                _buildExerciseCard(context, "assets/images/alarm.png", "운동 알림설정", AlarmListPage()),
                // _buildExerciseCard(context, "assets/images/chatbot.png", "챗봇", ChatbotPage()),
              ],
            ),
          ),
        ],
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