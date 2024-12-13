import 'package:fitchecker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'components/notification_helper.dart';
void main() async {
  // .env 파일 로드
  await dotenv.load(fileName: "assets/config/.env");
  final String appkey = dotenv.get("KAKAO_APP_KEY");
  print(appkey);

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: appkey);

  // Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // FirebaseMessaging 인스턴스를 초기화하고 토큰을 가져옴
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // FCM 토큰 가져오기
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  runApp(const MyApp());
  // NotificationHelper 초기화
  final NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initializeNotifications();

  runApp(
    Provider<NotificationHelper>(
      create: (_) => notificationHelper,
      child: MyApp(),
    ),
  );
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
