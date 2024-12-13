import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fitchecker/components/notification_helper.dart';
import 'package:fitchecker/screens/cache_management_screen.dart';
import 'package:fitchecker/screens/login_screen.dart';
import 'package:fitchecker/screens/notice_screen.dart';


class SettingsScreen extends StatefulWidget { // 수정: StatefulWidget으로 변경
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  late bool _isNotificationOn; // 알림 상태 관리


  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  // 알림 상태를 로드하는 함수
  Future<void> _loadNotificationPreference() async {
    final notificationHelper =
    Provider.of<NotificationHelper>(context, listen: false);
    bool preference = await notificationHelper.getNotificationPreference();
    setState(() {
      _isNotificationOn = preference;
    });
  }


  // 로그아웃 함수
  Future<void> _signOut(BuildContext context) async {
    try {
      // 구글 로그아웃
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _auth.currentUser?.reload();
      print("로그아웃 성공!");

      // 로그아웃 후 로그인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print('로그아웃 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그아웃 실패: $e")),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationHelper = Provider.of<NotificationHelper>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                ListTile(
                  title: const Text('알림 설정'),
                  trailing: Switch(
                    value: _isNotificationOn,
                    onChanged: (value) async {
                      await notificationHelper.setNotificationPreference(value);
                      setState(() {
                        _isNotificationOn = value; // 상태 업데이트
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? "알림이 켜졌습니다."
                              : "알림이 꺼졌습니다."),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(), // 구분선
                ListTile(
                  title: const Text('공지사항'), // 공지사항 항목
                  onTap: () {
                    // 공지사항 클릭 시 NoticeScreen으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NoticeScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트 간 간격을 띄움
                    children: const [
                      Text('버전 정보'), // 버전 정보 제목
                      Text('1.0.(현재버전)'), // 현재 버전 표시
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('캐시 데이터 삭제'), // 캐시 데이터 삭제 항목
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CacheManagementScreen())
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('로그아웃'), // 로그아웃 항목
                  onTap: () async {
                    await _signOut(context); // 로그아웃 처리
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('탈퇴하기'), // 계정 탈퇴 항목
                  onTap: () {
                    // 계정 탈퇴 처리 로직 추가 필요
                    print('계정 탈퇴 클릭됨');
                  },
                ),
                const Divider(), // 구분선
              ],
            ),
          ),
        ],
      ),
    );
  }
}


void main() {
  runApp(
    MaterialApp(
      home: SettingsScreen(), // 기본 화면 설정
    ),
  );
}