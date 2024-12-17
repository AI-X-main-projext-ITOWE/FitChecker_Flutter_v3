import 'package:fitchecker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'components/fcm_notificationService.dart';
import 'components/notification_helper.dart';  // Provider import

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  // 1. Flutter Local Notifications 초기화
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 2. FCM 백그라운드 메시지 핸들러
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");

    Map<String, dynamic> data = message.data;

    // 로그로 데이터 확인
    print("Title: ${data['title']}");
    print("Body: ${data['body']}");
    print("Response: ${data['response']}");
  }

  // 3. Notification 채널 설정
  Future<void> setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification; // notification 필드
      AndroidNotification? android = message.notification?.android;
      Map<String, dynamic> data = message.data; // data 필드

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? data['title'], // notification 없으면 data 사용
          notification.body ?? data['body'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // 채널 ID
              'High Importance Notifications', // 채널 이름
              channelDescription: 'This channel is used for important notifications.',
              priority: Priority.high, // 우선순위 설정
              importance: Importance.max,
              icon: 'launch_background',
            ),
          ),
        );

        // 추가 데이터(response) 로그 출력
        if (data['response'] != null) {
          print("Response: ${data['response']}");
        }
      }
    });
  }

  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: "assets/config/.env");
  final String appkey = dotenv.get("KAKAO_APP_KEY");

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: appkey);

  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 설정
  await setupNotificationChannel();
  setupFCMListener();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  // 알람 서비스 초기화
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

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
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}