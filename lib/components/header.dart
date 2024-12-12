import 'package:fitchecker/components/bouncyText.dart';
import 'package:flutter/material.dart';

import '../scrreens/notifications_screen.dart';
import '../scrreens/settings_screen.dart';

class Header extends StatelessWidget {
  final double height;

  Header({required this.height});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      title: BouncyText(
        text: 'FITCHECKER',
        style: TextStyle(
          fontFamily: 'happyzcool',
          color: Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: 16,
          letterSpacing: 2.0,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(onPressed: (){
          Navigator.of(context).push(
            PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => NotificationsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // 애니메이션 설정: 슬라이드 애니메이션
                const begin = Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        }, icon: Icon(Icons.notifications, color: Colors.white,)),
        IconButton(onPressed: (){
          Navigator.of(context).push(
            PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // 애니메이션 설정: 슬라이드 애니메이션
                const begin = Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        }, icon: Icon(Icons.settings, color: Colors.white,))
      ],
    );
  }
}