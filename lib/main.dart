import 'package:fitchecker/scrreens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

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

  runApp(const MyApp());
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