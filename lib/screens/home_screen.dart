import 'package:fitchecker/components/choice_exercise.dart';
import 'package:fitchecker/components/footer.dart';
import 'package:fitchecker/components/header.dart';
import 'package:fitchecker/components/main_page.dart';
import 'package:fitchecker/components/snowfall_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<HomeScreen> {
  static const navigationMethodChannel = MethodChannel(
      'com.example.fitchecker/navigation');

  // 헤더, 풋터 Height 비율 0.1 = 디바이스의 10%
  final double headerAndFooterHeight = 0.1;

  // 현재 선택된 화면 인덱스
  int _currentIndex = 0;

  late PageController _pageController;

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
          setState(() async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),)
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSwiper(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenWidth = MediaQuery
            .of(context)
            .size
            .width; // 화면 너비


        return ClipRRect(
          borderRadius: BorderRadius.circular(40), // 모서리를 둥글게 설정 (0.5)
          child: Padding(
            padding: EdgeInsets.all(8.0), // 모든 방향에 패딩 8.0을 추가 (패딩 크기 변경 가능)
            child: Container(
              width: screenWidth * 0.9, // 화면 너비의 90%
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.1, // 화면 높이의 10%
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  final imagePaths = [
                    'assets/images/test_banner01.jpg',
                    'assets/images/test_banner02.jpg',
                    'assets/images/test_banner03.jpg',
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
                itemCount: 3, // 슬라이드 갯수
                autoplay: true,
              ),
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

  @override
  Widget build(BuildContext context)  {
    final double dynamicHeight = MediaQuery
        .of(context)
        .size
        .height * headerAndFooterHeight;

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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(dynamicHeight * 2),
            child: Header(
              height: dynamicHeight,
            ),
          ),
          body: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  // 스와이퍼 추가
                  _buildSwiper(context),

                  // PageView 아래에 배치
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: [
                        MainPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          ),
        ),
        // 고정된 플로팅 액션 버튼
        Positioned(
          bottom: 16,
          left: MediaQuery.of(context).size.width / 2 - 44, // 버튼 중앙 정렬
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C2FF2), // 보라색 (밝은 톤)
                  Color(0xFF6C2FF2), // 동일한 보라색 (그라데이션 느낌 유지)
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF5522B5).withOpacity(0.5), // 어두운 보라 그림자
                  offset: Offset(2, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChoiceExercise()),
                );
                setState(() {
                  _currentIndex = 0; // 필요한 초기화 로직
                  _pageController.jumpToPage(_currentIndex); // PageView 갱신
                });
              },
              elevation: 0, // 기본 그림자 제거
              backgroundColor: Colors.transparent, // 백그라운드 투명
              child: Icon(
                Icons.fitness_center,
                size: 36,
                color: Colors.white, // 아이콘 흰색
              ),
            ),
          ),
        ),
      ],
    );
  }
}