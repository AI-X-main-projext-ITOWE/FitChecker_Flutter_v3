import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 intl 패키지
import 'notice_detail_screen.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  // 날짜 포맷 함수
  String formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate(); // Timestamp를 DateTime으로 변환
    return DateFormat('yyyy-MM-dd').format(date); // yyyy-MM-dd 형식으로 변환
  }

  @override
  Widget build(BuildContext context) {
    // Firestore에서 날짜 오름차순(가장 오래된 항목부터)으로 데이터 가져오기
    final Stream<QuerySnapshot> noticesStream = FirebaseFirestore.instance
        .collection('notices')
        .orderBy('date', descending: true) // 오래된 항목부터 정렬
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: noticesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 문제가 발생했습니다.'));
          }

          final notices = snapshot.data?.docs ?? [];

          if (notices.isEmpty) {
            return const Center(child: Text('등록된 공지사항이 없습니다.'));
          }

          return ListView.separated(
            itemCount: notices.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notice = notices[index];
              final data = notice.data() as Map<String, dynamic>;
              final title = data['title'] ?? '제목 없음';
              final date = data['date'] is Timestamp
                  ? formatDate(data['date'] as Timestamp) // 날짜 포맷팅
                  : '날짜 없음';
              final content = data['content'] ?? '내용 없음';

              // 번호 계산 (오래된 공지사항부터 1번)
              final noticeNumber = notices.length - index;

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$noticeNumber. $title'),
                    Text(
                      date, // 포맷팅된 날짜 표시
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoticeDetailPage(
                        title: title,
                        content: content,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
