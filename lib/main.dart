import 'package:fitchecker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'components/notification_helper.dart';
void main() async {
  // Flutter 애플리케이션 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: "assets/config/.env");

  // Kakao SDK 초기화
  final String appkey = dotenv.get("KAKAO_APP_KEY");
  print(appkey);
  KakaoSdk.init(nativeAppKey: appkey);

  // Firebase 초기화
  await Firebase.initializeApp();

  // 백그라운드에서 Firebase 메시지 처리
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseMessaging _firebaseMessaging;
  String? _message = "No message received yet.";

  @override
  void initState() {
    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;

    // Firebase FCM Token 가져오기
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    // 포어그라운드에서 메시지 수신 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      setState(() {
        _message = message.notification?.body;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Demo")),
      body: Center(
        child: Text(_message ?? "No message received yet."),
      ),
    );
  }
}
