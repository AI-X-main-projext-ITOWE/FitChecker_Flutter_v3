import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  const SettingsScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '설정 화면',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _signOut(context);
              },
              child: const Text("로그아웃"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: const SettingsScreen(), // 기본 화면 설정
    ),
  );
}