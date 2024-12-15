import 'package:flutter/material.dart';

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
              Icons.person,
              size: 36,
              color: currentIndex == 1 ? Color(0xFF6C2FF2) : Colors.grey,
            ),
            onPressed: () => onTabSelected(1),
          ),
        ],
      ),
    );
  }
}
