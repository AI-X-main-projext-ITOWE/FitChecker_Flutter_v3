import 'package:flutter/material.dart';

class Footer extends StatelessWidget{
  final double height;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<BottomNavigationBarItem> navItems;

  Footer({
    required this.height,
    required this.currentIndex,
    required this.onTabSelected,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색상 (반투명)
              offset: Offset(0, -2), // 그림자 위치 (x, y)
              blurRadius: 4.0, // 그림자 흐림 정도
              spreadRadius: 0.5, // 그림자 확산 정도
            )
          ]
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        items: navItems,
        onTap: onTabSelected,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}