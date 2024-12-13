import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitchecker/models/user_model.dart';
import 'package:fitchecker/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitchecker/services/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {  // TickerProviderStateMixin 추가
  late final AnimationController _animationController; // AnimationController 추가
  late final SpinKitRing spinkit;  // late 키워드로 SpinKit 인스턴스를 선언

  @override
  void initState() {
    super.initState();
    _showSplash();

    // 로딩 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200),);

    // SpinKit 초기화
    spinkit = SpinKitRing(
      color: Colors.white,
      size: 100.0,
      controller: _animationController,
    );

    // 로딩 애니메이션 시작
    _animationController.repeat();
  }

  // 로고 화면을 1초 동안 보여주고, 로그인 상태 확인 후 화면 전환
  void _showSplash() async {
    await Future.delayed(const Duration(seconds: 3)); // 1초 대기
    _checkLoginStatus(); // 로그인 상태 확인
  }

  // 로그인 상태 확인 후 자동 로그인
  void _checkLoginStatus() async {
    try {
      // AuthService를 사용하여 Google 로그인 및 Firebase 인증 처리
      final user = await AuthService.signInWithGoogle();

      if (user != null) {
        // Firestore에서 해당 사용자 UID로 저장된 데이터 확인
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          // Firestore 데이터 가져오기
          final data = doc.data();
          if (data != null) {
            // UserModel 생성
            final userModel = UserModel(
              id: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? '',
              photoUrl: user.photoURL,
              age: data['age'] ?? '',
              height: data['height'] ?? '',
              weight: data['weight'] ?? '',
              gender: data['gender'] ?? '',
            );

            // age, height, weight 중 하나라도 비어 있으면 UserInfoScreen으로 이동
            if (userModel.age == null || userModel.height == null || userModel.weight == null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoScreen(user: user),
                ),
              );
            } else {
              // 모든 값이 존재하면 HomeScreen으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            }
          }
        } else {
          // Firestore에 사용자 정보가 없는 경우 UserInfoScreen으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        }
      } else {
        throw Exception("사용자 정보를 가져올 수 없습니다.");
      }
    } catch (e) {
      print('구글 로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구글 로그인 실패: $e')),
      );
    }
  }


  @override
  void dispose() {
    // AnimationController를 dispose()하여 Ticker 정리
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Stack 위젯을 화면 전체에 맞게 확장
        children: [
          // 배경으로 로고 이미지
          Image.asset(
            'assets/images/start_loading.png',  // 로고 이미지
            fit: BoxFit.cover, // 화면에 맞게 이미지 크기 조절
          ),
          // 다른 UI 요소들 (로고를 배경으로 놓고 추가적인 UI 요소 배치)
          Center(
            child: spinkit, // 예시로 로딩 인디케이터 추가
          ),
        ],
      ),
    );
  }
}