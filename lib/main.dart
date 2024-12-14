import 'package:fitchecker/screens/splash_screen.dart';
import 'package:fitchecker/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'components/notification_helper.dart';  // Provider import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: "assets/config/.env");

  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 설정
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  // 예제: 사용자 ID (로그인 구현 후 실제 사용자 ID로 교체)
  String userId = "12345";

  // 서버로 FCM 토큰 전송
  if (fcmToken != null) {
    final apiService = ApiService();
    await apiService.sendFcmToken(userId, fcmToken);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationHelper>(create: (_) => NotificationHelper()),  // NotificationHelper Provider 추가
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '푸시 알림 예제',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
