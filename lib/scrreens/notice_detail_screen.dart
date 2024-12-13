import 'package:flutter/material.dart';

class NoticeDetailPage extends StatelessWidget {
  final String title; // 공지사항 제목
  final String content; // 공지사항 내용

  const NoticeDetailPage({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목록'), // 제목 표시
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0), // AppBar 아래 여백 추가
            Text(
              title, // 제목 표시
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1.0, height: 30.0), // 제목 아래 구분선 추가
            Text(
              content, // 내용 표시
              style: const TextStyle(
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
