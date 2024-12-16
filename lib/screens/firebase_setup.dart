import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 백그라운드 메시지 핸들러
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("백그라운드 메시지 수신: ${message.messageId}");
}

/// Firebase 초기화 및 설정
Future<void> setupFirebaseMessaging() async {
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 토픽 구독 설정
  await messaging.subscribeToTopic("user1");

  // 백그라운드 메시지 핸들러 설정
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}