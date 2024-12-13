package com.example.fitchecker

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // 푸시 메시지가 수신되었을 때 처리하는 코드
        if (remoteMessage.data.isNotEmpty()) {
            // 데이터를 포함한 메시지 처리
            Log.d("FCM", "Message data payload: " + remoteMessage.data)
        }

        remoteMessage.notification?.let {
            // 알림 메시지 처리
            Log.d("FCM", "Message Notification Body: " + it.body)
        }
    }

    override fun onNewToken(token: String) {
        // 새로운 FCM 토큰 생성 시 처리
        Log.d("FCM", "Refreshed token: $token")
        // 서버에 토큰을 전송하는 코드를 추가할 수 있습니다.
    }
}
