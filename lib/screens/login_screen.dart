import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitchecker/screens/user_info_screen.dart';
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
          _buildBackgroundImage(),
          // 반투명 오버레이
          _buildOverlay(),
          // 중앙 컨텐츠
          _buildLoginContent(context),
        ],
      ),
    );
  }

  // 배경 이미지
  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 반투명 오버레이
  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
    );
  }

  // 중앙 로그인 컨텐츠
  Widget _buildLoginContent(BuildContext context) {
    return Center(
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
              label: "구글 로그인",
              iconPath: 'assets/images/google_icon.png',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              onTap: () => _signInWith(context, 'google'),
            ),
            const SizedBox(height: 20),
            // 카카오 로그인 버튼
            _buildLoginCard(
              context: context,
              label: "카카오 로그인",
              iconPath: 'assets/images/kakao_icon.png',
              backgroundColor: const Color(0xFFFFE812),
              textColor: Colors.black,
              onTap: () => _signInWith(context, 'kakao'),
            ),
            const SizedBox(height: 30),
          ],
        ),
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
      onTapDown: (_) => isPressed.value = true,
      onTapUp: (_) {
        isPressed.value = false;
        onTap();
      },
      onTapCancel: () => isPressed.value = false,
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

  // 로그인 처리 함수 (구글 또는 카카오)
  Future<void> _signInWith(BuildContext context, String provider) async {
    try {
      late dynamic user;

      if (provider == 'google') {
        user = await AuthService.signInWithGoogle();
      } else if (provider == 'kakao') {
        user = await _signInWithKakao();
      }

      if (user != null) {
        await _handleUserData(user, context);
      } else {
        throw Exception("사용자 정보를 가져올 수 없습니다.");
      }
    } catch (e) {
      print('$provider 로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$provider 로그인 실패: $e')),
      );
    }
  }

  // 카카오 로그인 처리
  Future<dynamic> _signInWithKakao() async {
    bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken token;
    token = isInstalled
        ? await UserApi.instance.loginWithKakaoTalk()
        : await UserApi.instance.loginWithKakaoAccount();

    print('카카오 로그인 성공: ${token.accessToken}');
    // 토큰을 기반으로 Firebase 연동 가능
    return token;
  }

  // 사용자 정보 처리 및 화면 이동
  Future<void> _handleUserData(dynamic user, BuildContext context) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
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

        if (userModel.age == null || userModel.height == null || userModel.weight == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfoScreen(user: user),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoScreen(user: user),
        ),
      );
    }
  }
}
