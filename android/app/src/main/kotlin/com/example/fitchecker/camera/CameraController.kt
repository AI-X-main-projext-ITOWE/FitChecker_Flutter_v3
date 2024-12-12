package com.example.fitchecker.camera

import android.content.Context
import android.util.Log
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.example.fitchecker.CameraNativeActivity
import com.example.fitchecker.checkervoice.CheckExerciseVoice
import com.example.fitchecker.checkervoice.SpeakManager
import com.example.fitchecker.draw.CameraCanvasView
import com.example.fitchecker.draw.CountTextCanvasView
import com.example.fitchecker.exercise.PoseLandmarkerMaker
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import java.util.Calendar
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class CameraController(
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner,
    private val countTextCanvasView: CountTextCanvasView,
    private val cameraCanvasView: CameraCanvasView,
    private val previewView: PreviewView,
    private val exercise: String,
    private val maxCounter: Int,
    private val maxSetNumber: Int
    ) {

    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private lateinit var poseLandmarker: PoseLandmarkerMaker
    private lateinit var checkExerciseVoice: CheckExerciseVoice
    private val speakManager: SpeakManager = SpeakManager()
    private var counter: Int = 0
    private var setNumber:Int = 1
    private var exerciseStatus: Boolean = true
    private var isDialogShown = false
    private var totalCounter: Int = 0
    init {

        poseLandmarker = PoseLandmarkerMaker(context) {
            result: PoseLandmarkerResult, mpImage: MPImage ->

            // 운동 카운터
            val cntAndStsAndExercise = poseLandmarker
                .poseExerciseResult(
                    result,
                    exercise,
                    counter,
                    exerciseStatus
                )

            counter = cntAndStsAndExercise[0] as Int
            exerciseStatus = cntAndStsAndExercise[1] as Boolean

            cameraCanvasView.setLandmarkPoints(
                result, mpImage.width,
                mpImage.height, exercise, counter
            )

            countTextCanvasView.setImageSizeAndCounter(
                mpImage.width,
                mpImage.height,
                exercise,
                counter,
                setNumber
            )


            try {
                checkExerciseVoice.checkExerciseVoice(exercise, result)
            } catch (e: Exception) {
                Log.e("보이스", "Error in coroutine: ${e.message}", e)
            }

            checkCounter()
        }
    }


    fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider
            .getInstance(context)

        checkExerciseVoice = CheckExerciseVoice(context, speakManager)

        cameraProviderFuture.addListener({
            // Used to bind the lifecycle of cameras to the lifecycle owner
            val cameraProvider: ProcessCameraProvider =
                cameraProviderFuture.get()

            val preview = Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(previewView.surfaceProvider)
                }

            // Select back camera as a default
            val cameraSelector: CameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA

            val imageAnalyzer = ImageAnalysis.Builder()
                .build()
                .also {
                    it.setAnalyzer(cameraExecutor) { imageProxy ->
                        try {
                            processPoseInference(
                                imageProxy)
                        } catch (e: Exception) {
                            Log.e(TAG, "Image Analysis 오류", e)
                        } finally {
                            imageProxy.close() // 항상 자원 해제
                        }
                    }
                }

            try {
                cameraProvider.unbindAll() // 기존 세션 해제
                cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalyzer
                )
            } catch (exc: Exception) {
                Log.e(TAG, "카메라 바인딩 실패", exc)
            }

        }, ContextCompat.getMainExecutor(context))
    }
    // 스트림 추론기
    private fun processPoseInference(
        imageProxy: ImageProxy
    ) {
        val frameTime = System.nanoTime()

        val bitmap = imageProxy.toBitmap()
        val rotation = imageProxy.imageInfo.rotationDegrees

        cameraCanvasView.setRotation(rotation)
        countTextCanvasView.setRotation(rotation)

        val mpImage = BitmapImageBuilder(bitmap).build()

        poseLandmarker.detectPoseAsync(mpImage, frameTime)
    }

    fun stopCamera() {
        try {
            // 2. 실행자 종료
            try {
                // 잠시 대기 후 강제 종료
                if (!cameraExecutor.awaitTermination(
                        1000, TimeUnit.MILLISECONDS)
                ) {
                    cameraExecutor.shutdownNow()
                }
            } catch (e: InterruptedException) {
                cameraExecutor.shutdownNow()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping camera", e)
        }finally {
            updateExerciseInfo()
            cameraExecutor.shutdown()
            poseLandmarker.close()
            cameraCanvasView.clear()
            checkExerciseVoice.onDestroy()
            (context as CameraNativeActivity).finish()
        }
    }

    fun checkCounter() {
        if (setNumber > maxSetNumber && !isDialogShown) {
            isDialogShown = true // Dialog 표시 상태로 설정
            showCompletionDialog()
        }

        if (counter >= maxCounter) {
            setNumber += 1
            totalCounter += counter
            counter = 0
        }
    }
    private fun showCompletionDialog() {
        val activity = context as CameraNativeActivity
        activity.runOnUiThread {
            val builder = android.app.AlertDialog.Builder(activity)
            builder.setTitle("운동 완료!!")
            builder.setMessage("운동을 더 하시겠습니까?")
            builder.setPositiveButton("예") { _, _ ->
                stopCamera()
                isDialogShown = false
                activity.navigateToFlutterPage("exerciseSelection")
            }
            builder.setNegativeButton("아니오") { _, _ ->
                stopCamera()
                isDialogShown = false
                activity.navigateToFlutterPage("home")
            }
            builder.setCancelable(false)
            builder.show()
        }
    }

    fun updateExerciseInfo() {
        val calendar = Calendar.getInstance()
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        val hour = calendar.get(Calendar.HOUR_OF_DAY)
        val minute = calendar.get(Calendar.MINUTE)
        val second = calendar.get(Calendar.SECOND)
        val exerciseEndTime = System.currentTimeMillis()
        val totalCounter = totalCounter

        (context as CameraNativeActivity).updateExerciseInfo(
            exercise,
            totalCounter,
            exerciseEndTime,
            "$year-$month-$day $hour:$minute:$second") // 카운트 값 업데이트
    }
    companion object {
        private const val TAG = "CameraController"
    }
}