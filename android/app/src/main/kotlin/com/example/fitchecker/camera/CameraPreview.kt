package com.example.fitchecker.camera

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.camera.view.PreviewView
import io.flutter.plugin.platform.PlatformView

class CameraPreview(
    private val context: Context,
) : PlatformView {
    private lateinit var previewView: PreviewView

    init {
        try {
            initializeComponents()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize components", e)
        }
    }

    private fun initializeComponents() {
        // PreviewView 초기화
        previewView = PreviewView(context).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
    }

    override fun getView(): View = previewView

    override fun dispose() {
        previewView.setOnClickListener(null)
        previewView.setOnTouchListener(null)
        previewView.removeAllViews()

        // layoutParams를 null로 설정하는 대신 부모에서 제거
        (previewView.parent as? ViewGroup)?.removeView(previewView)

        previewView.background = null
        previewView.visibility = View.GONE

        // 추가적인 정리 작업
        // 예: 카메라 세션 종료, 리소스 해제 등

        Log.d(TAG, "카메라 프리뷰 disposed")
    }

    companion object {
        private const val TAG = "CameraPreview"
    }
}