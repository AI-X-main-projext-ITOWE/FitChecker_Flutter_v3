import 'package:fitchecker/components/chatbot.dart';
import 'package:fitchecker/components/choice_exercise.dart';
import 'package:fitchecker/components/my_profile.dart';
import 'package:fitchecker/components/footer.dart';
import 'package:fitchecker/components/header.dart';
import 'package:fitchecker/components/main_page.dart';
import 'package:fitchecker/components/snowfall_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<HomeScreen> {
  static const navigationMethodChannel = MethodChannel('com.example.fitchecker/navigation');

  // 헤더, 풋터 Height 비율 0.1 = 디바이스의 10%
  final double headerAndFooterHeight = 0.1;

  // 현재 선택된 화면 인덱스
  int _currentIndex = 0;

  late PageController _pageController;

  // 네비게이션 바 아이템 리스트
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        "assets/images/main.png",
        width: 24,
        height: 24,
      ),
      label: '메인화면',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        "assets/images/exersice.png",
        width: 24,
        height: 24,
      ),
      label: '운동 선택',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        "assets/images/chating.png",
        width: 24,
        height: 24,
      ),
      label: '챗봇',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        "assets/images/my.png",
        width: 24,
        height: 24,
      ),
      label: '내 정보',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // 네이티브에서 화면 전환 요청 처리
    navigationMethodChannel.setMethodCallHandler((call) async {
      if (call.method == 'navigateTo') {
        final destination = call.arguments['destination'];
        if (destination == 'home') {
          // MainPage로 이동
          setState(() {
            _currentIndex = 0;
          });
          _pageController.jumpToPage(0);
        } else if (destination == 'exerciseSelection') {
          // ChoiceExercise로 이동
          setState(() {
            _currentIndex = 1;
          });
          _pageController.jumpToPage(1);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dynamicHeight = MediaQuery.of(context).size.height * headerAndFooterHeight;

    return Stack(
      children: [
        // 배경 이미지
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
            child: Image.asset(
              'assets/images/home_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 눈 내리는 효과
        Positioned.fill(
          child: SnowfallEffect(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          // 헤더
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(dynamicHeight * 2),
            child: Header(
              height: dynamicHeight,
            ),
          ),
          // 바디
          body: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), // 위 왼쪽 모서리 둥글게
              topRight: Radius.circular(30.0), // 위 오른쪽 모서리 둥글게
            ),
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
              color: Colors.white,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  MainPage(),
                  ChoiceExercise(),
                  Chatbot(
                    initialMessage: '',
                  ),
                  MyProfile(),
                ],
              ),
            ),
          ),
          // 풋터
          bottomNavigationBar: Footer(
            height: dynamicHeight,
            currentIndex: _currentIndex,
            onTabSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            navItems: _navItems,
          ),
        ),
      ],
    );
  }
}