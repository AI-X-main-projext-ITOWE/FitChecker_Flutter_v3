import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;

class AuthService {
  static final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 구글 로그인
  static Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);

      await _saveUserToFirestore(userCredential.user!);
      return userCredential.user;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

// 카카오 로그인 함수
  static Future<firebase_auth.User?> signInWithKakao(BuildContext context) async {
    try {
      bool isInstalled = await kakao_user.isKakaoTalkInstalled();
      kakao_user.OAuthToken token;

      if (isInstalled) {
        token = await kakao_user.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao_user.UserApi.instance.loginWithKakaoAccount();
      }

      print('카카오 로그인 성공: ${token.accessToken}');

      // Firebase 인증 자격 증명 생성
      final firebase_auth.OAuthCredential credential = firebase_auth.OAuthProvider("kakao.com").credential(
        accessToken: token.accessToken,
      );

      // Firebase로 로그인
      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Firestore에 사용자 정보 저장 (필요한 경우)
      await _saveKakaoUserToFirestore(userCredential.user!);


      return userCredential.user;
    } catch (e) {
      print('카카오 로그인 실패: $e');
      return null;
    }
  }


  // Firestore에 구글 사용자 정보 저장
  static Future<void> _saveUserToFirestore(firebase_auth.User user) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'provider': 'google',
      }, SetOptions(merge: true));

      print('구글 사용자 정보 Firestore에 저장됨');
    } catch (e) {
      print('Firestore 저장 실패: $e');
    }
  }

  // Firestore에 카카오 사용자 정보 저장
  static Future<void> _saveKakaoUserToFirestore(firebase_auth.User user) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        'provider': 'kakao',
      }, SetOptions(merge: true));

      print('카카오 사용자 정보 Firestore에 저장됨');
    } catch (e) {
      print('Firestore 저장 실패: $e');
    }
  }
}
