package com.example.fitchecker

import android.content.Context
import android.content.Intent
import com.example.fitchecker.camera.CameraPreview
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.camerax_demo/camera"
    private val CHANNEL_EXERCISE = "com.example.fitchecker/exercise"
    private var selectedExercise: String = "" // 기본 운동 설정
    private var maxCounter = 0
    private var maxSetNumber = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngineInstance = flutterEngine

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "camera_preview", CameraPreviewFactory()
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_EXERCISE).setMethodCallHandler { call, result ->
            if (call.method == "setExercise") {
                val exercise = call.argument<String>("exercise")
                val maxCounter = call.argument<Int>("reps")
                val maxSetNumber = call.argument<Int>("sets")
                if (exercise != null && maxCounter != null && maxSetNumber != null) {
                    setExercise(exercise, maxCounter, maxSetNumber)
                    result.success("Exercise set to $exercise")
                } else {
                    result.error("INVALID_ARGUMENT", "Exercise is null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openNativeScreen") {
                openNativeScreen()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openNativeScreen() {
        val intent = Intent(this, CameraNativeActivity::class.java)
        intent.putExtra("selectedExercise", selectedExercise)
        intent.putExtra("maxCounter", maxCounter)
        intent.putExtra("maxSetNumber", maxSetNumber)
        startActivity(intent)
    }

    class CameraPreviewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            return CameraPreview(context)
        }
    }

    private fun setExercise(exercise: String, maxCounter: Int, maxSetNumber: Int) {
        this.selectedExercise = exercise
        // Native 운동 선택 데이터 로그 출력
        this.maxCounter = maxCounter
        this.maxSetNumber = maxSetNumber
        println("Selected Exercise: $selectedExercise")
    }

    companion object {
        lateinit var flutterEngineInstance: FlutterEngine
    }

}