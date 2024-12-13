package com.example.fitchecker.messag

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FirebaseMessage", "From: ${remoteMessage.from}")

        remoteMessage.notification?.let {
            Log.d("FirebaseMessage", "Message Notification Body: ${it.body}")
        }
    }

    override fun onNewToken(token: String) {
        Log.d("FirebaseMessage", "Refreshed token: $token")
        // 서버에 토큰을 전송하거나 필요에 따라 처리
    }
}
