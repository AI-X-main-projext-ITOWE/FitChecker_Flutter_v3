import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitchecker/scrreens/user_info_screen.dart';
import 'package:fitchecker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fitchecker/models/user_model.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 반투명 오버레이
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // 중앙 컨텐츠
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 타이틀 텍스트
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sign in to continue",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // 구글 로그인 버튼
                  _buildLoginCard(
                    context: context,
                    label: "구글  로그인",
                    iconPath: 'assets/images/google_icon.png',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    onTap: () => _signInWithGoogle(context),
                  ),
                  const SizedBox(height: 20),
                  // 카카오 로그인 버튼
                  _buildLoginCard(
                    context: context,
                    label: "카카오 로그인",
                    iconPath: 'assets/images/kakao_icon.png',
                    backgroundColor: const Color(0xFFFFE812),
                    textColor: Colors.black,
                    onTap: () => _signInWithKakao(context),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그인 카드 위젯
  Widget _buildLoginCard({
    required BuildContext context,
    required String label,
    required String iconPath,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final ValueNotifier<bool> isPressed = ValueNotifier(false);

    return GestureDetector(
      onTapDown: (_) {
        isPressed.value = true;
      },
      onTapUp: (_) {

        isPressed.value = false;
        onTap();
      },
      onTapCancel: () {
        isPressed.value = false;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isPressed,
        builder: (context, pressed, child) {
          return AnimatedScale(
            scale: pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200,
                maxWidth: 300,
                minHeight: 60,
              ),
              child: Card(
                color: backgroundColor,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(2, 6),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(iconPath, height: 24),
                        const SizedBox(width: 15),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 구글 로그인 함수
  Future<void> _signInWithGoogle(BuildContext context) async {
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
              builder: (context) => UserInfoScreen(user: user),
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


// 카카오 로그인 함수
  Future<void> _signInWithKakao(BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;

      // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 그렇지 않으면 카카오 계정으로 로그인
      token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('카카오 로그인 성공: ${token.accessToken}');
      // Firebase 연동 또는 사용자 데이터 처리

      // 로그인 성공 후 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      );
    } catch (e) {
      print('카카오 로그인 실패: $e');
    }
  }
}