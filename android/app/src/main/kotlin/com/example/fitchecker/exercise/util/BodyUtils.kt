package com.example.fitchecker.exercise.util

import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2

fun calculateAngle(
    bodyPart1:List<Float>,
    bodyPart2:List<Float>,
    bodyPart3:List<Float>
): Double {
    val bp1X = bodyPart1[0]
    val bp1Y = bodyPart1[1]

    val bp2X = bodyPart2[0]
    val bp2Y = bodyPart2[1]

    val bp3X = bodyPart3[0]
    val bp3Y = bodyPart3[1]

    // 각도 계산 (라디안 단위)
    val radians = atan2(bp3Y - bp2Y, bp3X - bp2X) - atan2(bp1Y - bp2Y, bp1X - bp2X)
    var angle = abs(radians * 180.0 / PI) // 라디안을 각도로 변환

    // 각도가 180도를 넘으면 360도에서 빼서 보정
    if (angle > 180.0) {
        angle = 360.0 - angle
    }

    return angle
}

fun detectionBodyParts(
    landmarkers:List<NormalizedLandmark>,
    landmarkNameIdx:Int
): List<Float> {
    // 단일 사람에 대한 포즈 랜드마크를 순회
    val landmarks = landmarkers[landmarkNameIdx]
    val bodyPart = listOf(
        landmarks.x(), landmarks.y()
        ,landmarks.z(), landmarks.visibility().orElse(0.0F))

    return bodyPart
}
