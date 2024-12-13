package com.example.fitchecker

import android.app.Application
import com.google.firebase.FirebaseApp

class FitCheckerApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Firebase 초기화 (필요시)
        FirebaseApp.initializeApp(this)
    }
}
