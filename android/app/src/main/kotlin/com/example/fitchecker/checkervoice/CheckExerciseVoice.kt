package com.example.fitchecker.checkervoice

import android.content.Context
import android.util.Log
import com.example.fitchecker.exercise.util.compareAngle
import com.example.fitchecker.exercise.util.executeCheckExercise
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult

class CheckExerciseVoice(
    private val context: Context,
    private val speakManager: SpeakManager
) {
    private var isLeftCheckStarted = false
    private var isRightCheckStarted = false
    private var leftStartExerciseTime: Long = 0L
    private var rightStartExerciseTime: Long = 0L
    init {
        speakManager.audioFromAssets(context)
    }
    fun checkExerciseVoice(exercise: String, result: PoseLandmarkerResult) {
        val bodyInfo = executeCheckExercise(exercise, result)

        val leftBodyInfo = bodyInfo["left"] as MutableList<Any>
        val rightBodyInfo = bodyInfo["right"] as MutableList<Any>

        val leftAngle = leftBodyInfo[4] as Double
        val leftCheckExercise = leftBodyInfo[5] as List<Any>
        val leftCode = leftCheckExercise[1] as Int

        val rightAngle = rightBodyInfo[4] as Double
        val rightCheckExercise = rightBodyInfo[5] as List<Any>
        val rightCode = rightCheckExercise[1] as Int

        val compareResult = compareAngle(leftAngle, rightAngle)
        val side = compareResult[0] as String
        val isCollectSide = compareResult[1] as Boolean

        if(leftCode == 0 && rightCode == 0) {
            if(side == "left" && !isCollectSide) {
                speakManager.playAudio(side)
            }else if (side == "right" && !isCollectSide) {
                speakManager.playAudio(side)
            }
        }
    }

    private fun checkExercise(isCheckExercise: Boolean, code: Int, side: String) {
        var startExerciseTime = getStartExerciseTime(side)
        val currentTime = (System.currentTimeMillis() - startExerciseTime) / 1000
        var isCheckingStarted = getIsCheckStarted(side)

        if (isCheckExercise && !isCheckingStarted && code == 1 && startExerciseTime == 0L) {
            isCheckingStarted = true
            startExerciseTime = System.currentTimeMillis()
        } else if (isCheckExercise && isCheckingStarted && code == 0) {
            isCheckingStarted = false
            startExerciseTime = 0L
        } else if (isCheckingStarted && currentTime >= 1 && code == 1 && startExerciseTime > 0L) {
            Log.d("CheckExerciseVoice", "음성 재생 시작")
            startExerciseTime = 0L
            speakManager.playAudio(side)
        }

        setIsCheckStarted(side, isCheckingStarted)
        setStartExerciseTime(side, startExerciseTime)
    }

    private fun getIsCheckStarted(side: String): Boolean {
        if( side == "left") {
            return isLeftCheckStarted
        }
        else {
            return isRightCheckStarted
        }
    }

    private fun setIsCheckStarted(side: String, isCheckStarted: Boolean) {
        if( side == "left") {
            isLeftCheckStarted = isCheckStarted
        }
        else {
            isRightCheckStarted = isCheckStarted
        }
    }

    private fun getStartExerciseTime(side: String): Long {
        if( side == "left") {
            return leftStartExerciseTime
        }
        else {
            return rightStartExerciseTime
        }
    }

    private fun setStartExerciseTime(side: String, startExerciseTime: Long) {
        if( side == "left") {
            leftStartExerciseTime = startExerciseTime
        }
        else {
            rightStartExerciseTime = startExerciseTime
        }
    }

    fun onDestroy() {
        speakManager.cancel()
    }
}
