import 'package:flutter/material.dart';
import 'package:fitchecker/components/chatbot.dart';

class Footer extends StatelessWidget {
  final double height;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  Footer({
    required this.height,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(), // 중앙을 동그랗게 만듦
      notchMargin: 6.0, // 튀어나온 버튼과의 간격
      color: Colors.white, // 풋터 배경 색상
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 메인화면 버튼
          IconButton(
            icon: Icon(
              Icons.home,
              size: 36,
              color: currentIndex == 0 ? Color(0xFF6C2FF2) : Colors.grey,
            ),
            onPressed: () => onTabSelected(0),
          ),
          // 운동 선택 버튼
          SizedBox(width: 48), // 챗봇 FloatingActionButton 공간
          // 내 정보 버튼
          IconButton(
            icon: Icon(
              Icons.chat_outlined,
              size: 36,
              color: currentIndex == 1 ? Color(0xFF6C2FF2) : Colors.grey,
            ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 300), // 전환 애니메이션 시간
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Chatbot(initialMessage: ''),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      // 오른쪽에서 슬라이드 전환
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(1.0, 0.0), // 오른쪽에서 시작
                          end: Offset.zero, // 화면의 원래 위치
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}
