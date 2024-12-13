import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'), // AppBar의 제목 설정
      ),
      body: Center(
        child: Text(
          '알림 화면', // 본문에 텍스트 표시
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificationsScreen(), // 기본 화면 설정
  ));
}