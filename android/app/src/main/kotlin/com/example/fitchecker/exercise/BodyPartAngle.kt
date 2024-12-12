package com.example.fitchecker.exercise

import com.example.fitchecker.exercise.util.calculateAngle
import com.example.fitchecker.exercise.util.detectionBodyParts
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import kotlin.math.abs

open class BodyPartAngle(landmarks: List<NormalizedLandmark>) {
    private val landmarkNames = mapOf(
        0 to "nose",
        1 to "left eye (inner)",
        2 to "left eye",
        3 to "left eye (outer)",
        4 to "right eye (inner)",
        5 to "right eye",
        6 to "right eye (outer)",
        7 to "left ear",
        8 to "right ear",
        9 to "mouth (left)",
        10 to "mouth (right)",
        11 to "left shoulder",
        12 to "right shoulder",
        13 to "left elbow",
        14 to "right elbow",
        15 to "left wrist",
        16 to "right wrist",
        17 to "left pinky",
        18 to "right pinky",
        19 to "left index",
        20 to "right index",
        21 to "left thumb",
        22 to "right thumb",
        23 to "left hip",
        24 to "right hip",
        25 to "left knee",
        26 to "right knee",
        27 to "left ankle",
        28 to "right ankle",
        29 to "left heel",
        30 to "right heel",
        31 to "left foot index",
        32 to "right foot index"
    )
    val landmark = landmarks
    fun angleOfLeftArm(): Double {

        val leftShoulder = detectionBodyParts(landmark, 11)
        val leftElbow = detectionBodyParts(landmark, 13)
        val leftWrist = detectionBodyParts(landmark, 15)

        return calculateAngle(leftShoulder, leftElbow, leftWrist)
    }
    fun angleOfRightArm(): Double {

        val rightShoulder = detectionBodyParts(landmark, 12)
        val rightElbow = detectionBodyParts(landmark, 14)
        val rightWrist = detectionBodyParts(landmark, 16)

        return calculateAngle(rightShoulder, rightElbow, rightWrist)
    }

    fun angleOfLeftElbow(): Double {

        val leftElbow = detectionBodyParts(landmark, 13)
        val leftShoulder = detectionBodyParts(landmark, 11)
        val leftHip = detectionBodyParts(landmark, 23)

        return calculateAngle(leftElbow, leftShoulder, leftHip)
    }

    fun angleOfRightElbow(): Double {

        val rightElbow = detectionBodyParts(landmark, 14)
        val rightShoulder = detectionBodyParts(landmark, 12)
        val rightHip = detectionBodyParts(landmark, 24)

        return calculateAngle(rightElbow, rightShoulder, rightHip)
    }

    fun angleOfLeftLeg(): Double {

        val leftHip = detectionBodyParts(landmark, 23)
        val leftKnee = detectionBodyParts(landmark, 25)
        val leftAnkle = detectionBodyParts(landmark, 27)

        return calculateAngle(leftHip, leftKnee, leftAnkle)
    }

    fun angleOfRightLeg(): Double {

        val rightHip = detectionBodyParts(landmark, 24)
        val rightKnee = detectionBodyParts(landmark, 26)
        val rightAnkle = detectionBodyParts(landmark, 28)

        return calculateAngle(rightHip, rightKnee, rightAnkle)
    }
    fun angleOfNeck(): Double {

        val leftShoulder = detectionBodyParts(landmark, 11)
        val rightShoulder = detectionBodyParts(landmark, 12)

        val shoulderAvg = listOf((leftShoulder[0] + rightShoulder[0]) / 2
            , (leftShoulder[1] + rightShoulder[1]) / 2)

        val leftMouth = detectionBodyParts(landmark, 9)
        val rightMouth = detectionBodyParts(landmark, 10)

        val mouthAvg = listOf((leftMouth[0] + rightMouth[0]) / 2
            , (leftMouth[1] + rightMouth[1]) / 2)

        val leftHip = detectionBodyParts(landmark, 23)
        val rightHip = detectionBodyParts(landmark, 24)

        val hipAvg = listOf((leftHip[0] + rightHip[0]) / 2
            , (leftHip[1] + rightHip[1]) / 2)


        return abs(180F - calculateAngle(shoulderAvg, mouthAvg, hipAvg))
    }

    fun angleOfAbdomen(): Double {

        val leftShoulder = detectionBodyParts(landmark, 11)
        val rightShoulder = detectionBodyParts(landmark, 12)

        val shoulderAvg = listOf((leftShoulder[0] + rightShoulder[0]) / 2
            , (leftShoulder[1] + rightShoulder[1]) / 2)


        val leftHip = detectionBodyParts(landmark, 23)
        val rightHip = detectionBodyParts(landmark, 24)

        val hipAvg = listOf((leftHip[0] + rightHip[0]) / 2
            , (leftHip[1] + rightHip[1]) / 2)

        val leftKnee = detectionBodyParts(landmark, 25)
        val rightKnee = detectionBodyParts(landmark, 26)

        val KneeAvg = listOf((leftKnee[0] + rightKnee[0]) / 2
            , (leftKnee[1] + rightKnee[1]) / 2)

        return calculateAngle(shoulderAvg, hipAvg, KneeAvg)
    }
}