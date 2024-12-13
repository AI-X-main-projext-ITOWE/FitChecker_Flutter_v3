import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHelper {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

      await _localNotificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print("알림 클릭됨");
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'fitchecker_channel',
        '운동 알림',
        description: 'FitChecker 앱의 기본 알림 채널입니다.',
        importance: Importance.high,
      );

      final androidPlugin = _localNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
      }
      print("알림 초기화 완료");
    } catch (e) {
      print('알림 초기화 실패: $e');
    }
  }

  Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isOn = prefs.getBool('isNotificationOn') ?? true;
    print("알림 상태 로드: $isOn");
    return isOn;
  }

  Future<void> setNotificationPreference(bool isOn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationOn', isOn);

    if (isOn) {
      print("알림 활성화됨");
    } else {
      print("알림 비활성화됨");
      await _localNotificationsPlugin.cancelAll();
    }
  }
}
