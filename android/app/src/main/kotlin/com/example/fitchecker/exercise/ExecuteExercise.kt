package com.example.fitchecker.exercise

import com.example.fitchecker.exercise.util.checkPullUp
import com.example.fitchecker.exercise.util.checkPushUp
import com.example.fitchecker.exercise.util.checkSitUp
import com.example.fitchecker.exercise.util.checkSquat
import com.example.fitchecker.exercise.util.detectionBodyParts
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark

class ExecuteExercise(landmarks: List<NormalizedLandmark>) : BodyPartAngle(landmarks) {

    private fun pushUp(counter:Int, status:Boolean): List<Any> {
        var cnt = counter
        var sts = status
        val leftArmAngle = angleOfLeftArm()
        val rightArmAngle = angleOfRightArm()
        val avgArmAngle = (leftArmAngle + rightArmAngle) / 2F
        val pushUp = checkPushUp(avgArmAngle)

        val statusPushUp = pushUp[0] as Boolean
        val code = pushUp[1] as Int

        if (sts) {
            if (statusPushUp && code == 0) {
                cnt += 1
                sts = false
            }
        }
        else {
            if(statusPushUp && code == 1) {
                sts = true
            }
        }

        return listOf(cnt, sts)
    }

    private fun pullUp(counter: Int, status: Boolean): List<Any> {
        var cnt = counter
        var sts = status

        val leftWrist = detectionBodyParts(landmark, 15)
        val rightWrist = detectionBodyParts(landmark, 16)
        val leftArm = angleOfLeftArm()
        val rightArm = angleOfRightArm()
        val leftElbow = angleOfLeftElbow()
        val rightElbow = angleOfRightElbow()

        val avgArm = (leftArm + rightArm) / 2
        val avgElbow = (leftElbow + rightElbow) / 2

        val pullUp = checkPullUp(avgArm, avgElbow)

        val statusPullUp = pullUp[0] as Boolean
        val code = pullUp[1] as Int

        if(leftWrist[3] >= 0.7f && rightWrist[3] >= 0.7f) {
            if (sts) {
                if(statusPullUp && code == 0) {
                    cnt += 1
                    sts = false
                }
            }else {
                if(statusPullUp && code == 1) {
                    sts = true
                }
            }
        }


        return listOf(cnt, sts)
    }

    private fun squat(counter: Int, status: Boolean): List<Any> {
        var cnt = counter
        var sts = status
        val leftLegAngle = angleOfLeftLeg()
        val rightLegAngle = angleOfRightLeg()
        val avgLegAngle = (leftLegAngle + rightLegAngle) / 2F
        val squat = checkSquat(avgLegAngle)

        val statusSquat = squat[0] as Boolean
        val code = squat[1] as Int

        if (sts) {
            if(statusSquat && code == 0) {
                cnt += 1
                sts = false
            }
        }
        else {
            if(statusSquat && code == 1) {
                sts = true
            }
        }

        return listOf(cnt, sts)
    }

    private fun sitUp(counter: Int, status: Boolean): List<Any> {
        var cnt = counter
        var sts = status
        val abdomenAngle = angleOfAbdomen()
        val sitUp = checkSitUp(abdomenAngle)

        val statusSitUp = sitUp[0] as Boolean
        val code = sitUp[1] as Int

        if (sts) {
            if(statusSitUp&& code == 0) {
                cnt += 1
                sts = false
            }
        }
        else {
            if(statusSitUp && code == 1) {
                sts = true
            }
        }

        return listOf(cnt, sts)
    }

    fun calculateExercise(exerciseTypeName: String, counter: Int, status: Boolean): List<Any> {
        return when (exerciseTypeName) {
            "push-up" -> pushUp(counter, status)
            "pull-up" -> pullUp(counter, status)
            "squat" -> squat(counter, status)
            "sit-up" -> sitUp(counter, status)
            else -> listOf(counter, status)
        }
    }
}