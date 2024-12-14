import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String _apiUrl = "localhost:8000/api/v1/agent";

  // FCM 토큰 전송 함수
  Future<void> sendFcmToken(String userId, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "fcmToken": fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print("FCM 토큰 전송 성공");
      } else {
        print("서버 오류: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("FCM 토큰 전송 실패: $e");
    }
  }
}
