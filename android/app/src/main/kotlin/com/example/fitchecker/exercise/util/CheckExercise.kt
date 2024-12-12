package com.example.fitchecker.exercise.util

import com.google.common.collect.ImmutableMap
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult


fun compareAngle(leftAngle: Double, rightAngle: Double): List<Any> {
    val leftAndRightList = mutableListOf<Any>("great", true)
    val rightMinRageAngle = rightAngle - 15
    val rightMaxRageAngle = rightAngle + 15

    if(leftAngle !in rightMinRageAngle..rightMaxRageAngle) {
        leftAndRightList[1] = false
    }

    if (leftAndRightList[1] as Boolean) {
        leftAndRightList[0] = "great"

        return leftAndRightList
    }
    else if (leftAngle > rightAngle) {
        leftAndRightList[0] = "left"
    }else {
        leftAndRightList[0] = "right"
    }

    return leftAndRightList
}
fun checkPushUp(avgArmAngle:Double):List<Any> {

    if (avgArmAngle < 75)
        return listOf(true, 0)

    else if(avgArmAngle > 160)
        return listOf(true, 1)

    return listOf(false, 2)
}

fun checkPullUp(avgArmAngle: Double, avgElbowAngle: Double):List<Any> {

    if(avgArmAngle <= 70)
        return listOf(true, 0)

    else if(avgArmAngle > 110 && avgElbowAngle > 150)
        return listOf(true, 1)

    return listOf(false, 2)
}

fun checkSquat(avgLegAngle: Double): List<Any> {

    if(avgLegAngle < 75)
        return listOf(true, 0)

    else if(avgLegAngle > 160)
        return listOf(true, 1)

    return listOf(false, 2)
}

fun checkSitUp(abdomenAngle: Double):List<Any> {

    if(abdomenAngle < 55)
        return listOf(true, 0)

    else if(abdomenAngle > 105)
        return listOf(true, 1)

    return listOf(false, 2)
}

fun executeCheckExercise(
    exercise: String,
    poseLandmarkerResult: PoseLandmarkerResult ): ImmutableMap<String, MutableList<Any>> {
        return ImmutableMap.copyOf(checkExercise(poseLandmarkerResult, exercise))
}

private fun checkExercise(
    poseLandmarkerResult: PoseLandmarkerResult,
    exercise: String ): MutableMap<String, MutableList<Any>> {

    var mapPart = mutableMapOf(
        "left" to mutableListOf<Any>(),
        "right" to mutableListOf<Any>()
    )
    val angleIndices = when(exercise) {
        "push-up" -> Triple(1, 2, 3)
        "pull-up" -> Triple(1, 2, 3)
        "squat" -> Triple(1, 2, 3)
        "sit-up" -> Triple(0, 1, 2)
        else -> Triple(1, 2, 3)
    }
    when(exercise) {
        "push-up" -> {
            val pushUpBodyParts = listOf(23, 11, 13, 15)
            mapPart = getCheckExerciseData(mapPart, poseLandmarkerResult, pushUpBodyParts, angleIndices)

            mapPart["left"]!!.add(checkPushUp(mapPart["left"]!![4] as Double))
            mapPart["right"]!!.add(checkPushUp(mapPart["right"]!![4] as Double))

        }
        "pull-up" -> {
            val pullUpBodyParts = listOf(23, 11, 13, 15)
            val pullUpElbowBodyParts = listOf(15, 13, 11, 23)
            var mapElbowPart = mutableMapOf(
                "left" to mutableListOf<Any>(),
                "right" to mutableListOf<Any>()
            )

            mapPart = getCheckExerciseData(mapPart, poseLandmarkerResult, pullUpBodyParts, angleIndices)
            mapElbowPart = getCheckExerciseData(mapElbowPart, poseLandmarkerResult, pullUpElbowBodyParts, angleIndices)

            mapPart["left"]!!.add(checkPullUp(
                    mapPart["left"]!![4] as Double,
                    mapElbowPart["left"]!![4] as Double
                )
            )
            mapPart["right"]!!.add(checkPullUp(
                    mapPart["right"]!![4] as Double,
                    mapElbowPart["right"]!![4] as Double
                )
            )

        }
        "squat" -> {
            val squatBodyParts = listOf(11, 23, 25, 27)
            mapPart = getCheckExerciseData(mapPart, poseLandmarkerResult, squatBodyParts, angleIndices)

            mapPart["left"]!!.add(checkSquat(mapPart["left"]!![4] as Double))
            mapPart["right"]!!.add(checkSquat(mapPart["right"]!![4] as Double))
        }
        "sit-up" -> {
            val sitUpBodyParts = listOf(11, 23, 25, 27)
            mapPart = getCheckExerciseData(mapPart, poseLandmarkerResult, sitUpBodyParts, angleIndices)

            mapPart["left"]!!.add(checkSitUp(mapPart["left"]!![4] as Double))
            mapPart["right"]!!.add(checkSitUp(mapPart["right"]!![4] as Double))
        }
    }

    return mapPart
}

private fun getCheckExerciseData(
    mapPart: MutableMap<String, MutableList<Any>>,
    poseLandmarkerResult: PoseLandmarkerResult,
    landNumbers: List<Int>,
    angleIndices: Triple<Int, Int, Int>
): MutableMap<String, MutableList<Any>> {

    landNumbers.forEach { landNumber ->
        mapPart["left"]!!.add(getLandmark(poseLandmarkerResult, landNumber))
        mapPart["right"]!!.add(getLandmark(poseLandmarkerResult, landNumber + 1))
    }

    val leftBodyPartA = mapPart["left"]!![angleIndices.first] as List<Float>
    val leftBodyPartB = mapPart["left"]!![angleIndices.second] as List<Float>
    val leftBodyPartC = mapPart["left"]!![angleIndices.third] as List<Float>

    val leftAngle = calculateAngle( leftBodyPartA, leftBodyPartB, leftBodyPartC)

    val rightBodyPartA = mapPart["right"]!![angleIndices.first] as List<Float>
    val rightBodyPartB = mapPart["right"]!![angleIndices.second] as List<Float>
    val rightBodyPartC = mapPart["right"]!![angleIndices.third] as List<Float>

    val rightAngle = calculateAngle( rightBodyPartA, rightBodyPartB, rightBodyPartC)

    mapPart["left"]!!.add(leftAngle)
    mapPart["right"]!!.add(rightAngle)

    return mapPart
}

private fun getLandmark(
    poseLandmarkerResult: PoseLandmarkerResult,
    landNumber:Int
): List<Float> {

    return listOf(
        poseLandmarkerResult.landmarks()[0][landNumber].x(),
        poseLandmarkerResult.landmarks()[0][landNumber].y()
    )
}