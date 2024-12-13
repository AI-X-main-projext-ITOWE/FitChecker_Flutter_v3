import 'package:fitchecker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'components/notification_helper.dart';

void main() async {
  // Flutter 애플리케이션 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: "assets/config/.env");

  // Kakao SDK 초기화
  final String appkey = dotenv.get("KAKAO_APP_KEY");
  KakaoSdk.init(nativeAppKey: appkey);

  // Firebase 초기화
  await Firebase.initializeApp();

  // NotificationHelper 초기화
  final NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initializeNotifications();

  // 백그라운드에서 Firebase 메시지 처리
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  runApp(
    Provider<NotificationHelper>(
      create: (_) => notificationHelper,
      child: const MyApp(),
    ),
  );
}

// 백그라운드에서 메시지를 수신할 때 처리하는 함수
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("Background message received: ${message.notification?.title}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로그인 예제',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
