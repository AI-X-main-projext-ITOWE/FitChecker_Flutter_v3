import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_sdk;

class AuthService {
  // 구글 로그인
  static Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("구글 로그인 실패: $e");
      return null;
    }
  }

  // 카카오 로그인
  static Future<firebase_auth.User?> signInWithKakao() async {
    try {
      bool isInstalled = await kakao_sdk.isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await kakao_sdk.UserApi.instance.loginWithKakaoTalk()
          : await kakao_sdk.UserApi.instance.loginWithKakaoAccount();

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(
        OAuthProvider('kakao.com').credential(
          accessToken: token.accessToken,
        ),
      );
      return userCredential.user;
    } catch (e) {
      print("카카오 로그인 실패: $e");
      return null;
    }
  }
}
