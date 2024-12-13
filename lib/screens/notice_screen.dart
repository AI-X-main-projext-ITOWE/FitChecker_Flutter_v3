import 'package:flutter/material.dart';
import 'package:fitchecker/screens/notice_detail_screen.dart'; // 공통 상세 페이지를 위한 import

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 공지사항 예시 데이터 (등록 순서대로 추가)
    final List<Map<String, String>> notices = [
      {
        'title': 'AI 자세 교정 기능 업데이트!',
        'date': '2024-01-02',
        'content':
        'FitChecker에 새로운 AI 자세 교정 기능이 추가되었습니다!\n'
            '이제 더 정확하고 세밀한 자세 분석으로 여러분의 운동 효율을 높여드립니다.\n'
            '업데이트 후 새로운 기능을 확인해 보세요!'
      },
      {
        'title': '새로운 운동 프로그램 출시!',
        'date': '2024-01-03',
        'content':
        'FitChecker에서 사용자의 목표에 맞춘 새로운 운동 프로그램을 출시했습니다.\n'
            '체형 개선, 근력 강화, 유연성 향상 등 다양한 목표를 위한 프로그램을 확인하고 시작해 보세요!\n'
            '\'운동 프로그램\' 탭에서 확인할 수 있습니다.'
      },
      {
        'title': '운동 랭킹 시스템 오픈!',
        'date': '2024-01-04',
        'content':
        '드디어 기다리시던 운동 랭킹 시스템이 오픈되었습니다!\n'
            '매일 운동 기록을 남기고 다른 사용자와 순위를 비교해보세요.\n'
            '랭킹 1위에게는 특별한 혜택이 기다리고 있습니다!'
      },
    ];

    // 내림차순 정렬 (날짜 기준으로 최신 항목 위로)
    final sortedNotices = List.from(notices)
      ..sort((a, b) => b['date']!.compareTo(a['date']!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 여백
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30), // AppBar와 리스트 사이 여백 추가
            Expanded(
              child: ListView.separated(
                itemCount: sortedNotices.length,
                separatorBuilder: (context, index) =>
                const Divider(), // 각 항목 사이에 Divider 추가
                itemBuilder: (context, index) {
                  final notice = sortedNotices[index];
                  final noticeNumber =
                      sortedNotices.length - index; // 최신 공지사항이 1번

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$noticeNumber. ${notice['title']}'), // 제목 + 번호
                        Text(
                          notice['date']!, // 날짜 (오른쪽 정렬)
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // 공지사항 클릭 시 공통 상세 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticeDetailPage(
                            title: notice['title']!,
                            content: notice['content']!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
