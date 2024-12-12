package com.example.fitchecker

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.fitchecker.MainActivity.Companion.flutterEngineInstance
import com.example.fitchecker.camera.CameraController
import com.example.fitchecker.databinding.ActivityMainBinding
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.properties.Delegates


class CameraNativeActivity: AppCompatActivity() {
    private val CHANNEL_EXERCISE = "com.example.fitchecker/exercise"
    private val CHANNEL_NAVIGATION = "com.example.fitchecker/navigation"
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var viewBinding: ActivityMainBinding
    private lateinit var cameraController: CameraController
    private var exerciseStartTime by Delegates.notNull<Long>()


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine = flutterEngineInstance
        // ActionBar 숨기기
        if (getSupportActionBar() != null) {
            getSupportActionBar()?.hide()
        }
        viewBinding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(viewBinding.root)
        viewBinding.previewView.scaleType =
            PreviewView.ScaleType.FILL_CENTER

        val selectedExercise = intent.getStringExtra("selectedExercise") ?: ""
        val maxCounter = intent.getIntExtra("maxCounter", 0)
        val maxSetNumber = intent.getIntExtra("maxSetNumber", 0)
        Log.d(TAG, "선택된 운동: $selectedExercise") // 로그 추가

        exerciseStartTime = System.currentTimeMillis()

        cameraController = CameraController(
            this,
            this,
            viewBinding.countTextCanvasView,
            viewBinding.cameraCanvasView,
            viewBinding.previewView,
            selectedExercise,
            maxCounter,
            maxSetNumber
        )

        if (checkCameraPermission()) {
            cameraController.startCamera()
        } else {
            requestCameraPermission()
        }

        viewBinding.returnMain.setOnClickListener{ returnMain() }
    }

    private fun checkCameraPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestCameraPermission() {
        // 카메라 외에도 필요한 모든 권한을 한번에 요청
        ActivityCompat.requestPermissions(
            this,
            REQUIRED_PERMISSIONS,
            REQUEST_CODE_PERMISSIONS
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                Toast.makeText(this, "카메라 권한이 허용되었습니다.", Toast.LENGTH_SHORT).show()
                // 권한이 허용되었으므로, 카메라를 시작합니다.
                cameraController.startCamera()
            } else {
                Toast.makeText(this, "카메라 권한이 거부되었습니다. 이 기능을 사용하려면 권한이 필요합니다.", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (checkCameraPermission()) {
            Log.d(TAG, "onResume - 카메라 권한 확인 완료, 카메라 시작")
            cameraController.startCamera()
        } else {
            Log.w(TAG, "onResume - 카메라 권한이 없습니다.")
        }
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "onPause - 카메라 세션 해제")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy - 모든 리소스 해제")
    }

    companion object {
        private const val TAG = "CameraNativeActivity"
        private val CAMERA_PERMISSION_REQUEST_CODE = 1001
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
        private const val REQUEST_CODE_PERMISSIONS = 10
        private val REQUIRED_PERMISSIONS =

            mutableListOf (
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
            ).apply {
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
                    add(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                }
            }.toTypedArray()
    }

    private fun returnMain() {
        val intent = Intent(this, CameraNativeActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
        finish()
    }

    fun updateExerciseInfo(exercise: String, totalCounter: Int, exerciseEndTime: Long, exerciseDay:String, ) {
        val flutterEngine = flutterEngineInstance
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_EXERCISE)
        val exerciseTime = (exerciseEndTime - exerciseStartTime) / 1000

        // UI 스레드에서 실행
        runOnUiThread {
            methodChannel.invokeMethod("sendExerciseInfo", mapOf(
                "exercise" to exercise,
                "totalCounter" to totalCounter,
                "exerciseTime" to exerciseTime,
                "exerciseDay" to exerciseDay))
        }
    }

    fun navigateToFlutterPage(destination: String) {
        val flutterEngine = flutterEngineInstance
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAVIGATION)

        methodChannel.invokeMethod("navigateTo", mapOf(
            "destination" to destination))
    }
}


