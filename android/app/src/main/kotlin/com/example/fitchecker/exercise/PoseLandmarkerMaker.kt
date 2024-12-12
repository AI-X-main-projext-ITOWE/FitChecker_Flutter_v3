package com.example.fitchecker.exercise

import android.content.Context
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.OutputHandler
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult

class PoseLandmarkerMaker(
    context: Context,
    private val runner: OutputHandler.ResultListener<PoseLandmarkerResult, MPImage>
) {
    val poseLandmarker: PoseLandmarker

    init {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath("pose_landmarker_full.task") // 모델 파일 위치
            .build()

        val options =
            PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setMinPoseDetectionConfidence(0.7F)
                .setMinTrackingConfidence(0.9F)
                .setMinPosePresenceConfidence(0.7F)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setResultListener(runner)
                .build()

        poseLandmarker = PoseLandmarker.createFromOptions(context, options)
    }

    fun detectPoseAsync(mpImage: MPImage, timeStamp: Long) {
        poseLandmarker.detectAsync(mpImage, timeStamp)
    }

    fun close() {
        poseLandmarker.close()
    }
    
    fun poseExerciseResult(
        result: PoseLandmarkerResult,
        exercise: String,
        counter: Int,
        status: Boolean
    ): List<Any> {

        result.landmarks().forEach{landmarks ->
            val executeExercise = ExecuteExercise(landmarks)
                .calculateExercise(exercise, counter, status)

            return  listOf(executeExercise[0], executeExercise[1], exercise)
        }

        return listOf(counter, status)
    }

}
