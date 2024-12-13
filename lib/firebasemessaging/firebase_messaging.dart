import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 앱 초기화 및 FCM 설정
  static Future<void> initialize() async {
    // 포그라운드에서 메시지 수신 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM 메시지 받음: ${message.notification?.title}");
      // 알림을 사용자에게 표시하는 등의 처리
    });

    // 앱이 백그라운드나 종료 상태에서 FCM 메시지를 클릭했을 때 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("FCM 메시지 클릭: ${message.notification?.title}");
      // 메시지를 클릭했을 때의 동작 처리
    });

    // 백그라운드 상태에서 메시지 수신 처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 토큰 가져오기 및 서버에 전송
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // 서버로 토큰을 전송하는 함수 호출 (예: sendTokenToServer(token))
    if (token != null) {
      sendTokenToServer(token);  // 이 함수는 토큰을 서버로 전송하는 로직을 작성해야 합니다.
    }

    // 토큰 갱신 시 호출되는 콜백 설정
    messaging.onTokenRefresh.listen((newToken) {
      print("새로운 FCM 토큰: $newToken");
      // 서버에 새로운 토큰을 전송
      sendTokenToServer(newToken);
    });
  }

  // 백그라운드에서 수신된 메시지 처리
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("백그라운드 메시지: ${message.notification?.title}");
    // 백그라운드에서 메시지 처리
  }

  // 서버에 토큰을 전송하는 함수 (서버에서 FCM 메시지를 보낼 때 필요)
  static Future<void> sendTokenToServer(String token) async {
    // 서버에 토큰을 전송하는 로직을 작성합니다.
    // 예를 들어, HTTP 요청을 보내서 토큰을 서버로 전달합니다.
    print("서버로 토큰 전송: $token");

    // 서버로 HTTP 요청 보내는 예시 (Http 패키지 사용)
    /*
    final response = await http.post(
      Uri.parse("https://your-server.com/api/save-token"),
      body: {"token": token},
    );
    if (response.statusCode == 200) {
      print("서버에 토큰 저장 성공");
    } else {
      print("서버에 토큰 저장 실패");
    }
    */
  }
}
