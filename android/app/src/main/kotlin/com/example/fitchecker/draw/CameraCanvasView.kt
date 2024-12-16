package com.example.fitchecker.draw

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Typeface
import android.util.AttributeSet
import android.view.View
import com.example.fitchecker.exercise.util.executeCheckExercise
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import kotlin.math.max

class CameraCanvasView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
): View(context, attrs, defStyleAttr) {

    private var results: PoseLandmarkerResult? = null
    private var pointPaint = Paint()
    private var lineCollectPaint = Paint()
    private var lineWrongPaint = Paint()
    private var rotationPaint = Paint()
    private var scaleFactor: Float = 1f
    private var imageWidth: Int = 1
    private var imageHeight: Int = 1
    private var rotationDegrees: Int = 0
    private var counter: String = ""
    private val matrix = Matrix() // 행렬 객체
    private lateinit var exercise: String

    private  fun initPaints() {
        lineCollectPaint.color = Color.GREEN
        lineCollectPaint.strokeWidth = LANDMARK_STROKE_WIDTH
        lineCollectPaint.style = Paint.Style.STROKE
        lineCollectPaint.isAntiAlias = true

        lineWrongPaint.color = Color.RED
        lineWrongPaint.strokeWidth = LANDMARK_STROKE_WIDTH
        lineWrongPaint.style = Paint.Style.STROKE
        lineWrongPaint.isAntiAlias = true

        pointPaint.color = Color.YELLOW
        pointPaint.strokeWidth = LANDMARK_STROKE_WIDTH
        pointPaint.style = Paint.Style.FILL
        pointPaint.isAntiAlias = true

        rotationPaint.color = Color.WHITE
        rotationPaint.strokeWidth = LANDMARK_STROKE_WIDTH
        rotationPaint.typeface = Typeface.createFromAsset(context.assets, "fonts/cafe24ohsquare.ttf")
        rotationPaint.style = Paint.Style.FILL
        rotationPaint.textSize = 20f
        rotationPaint.isAntiAlias = true
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val xOffset = (width - imageWidth * scaleFactor) / 2f // 캔버스 중심으로 이동하기 위한 이동값
        val yOffset = (height - imageHeight * scaleFactor) / 2f //

        canvas.save() // 원래 상태 저장
        matrix.reset()

        setCameraPoseMatrix(xOffset, yOffset)

        canvas.concat(matrix)

        results?.let { poseLandmarkerResult ->
            for (landmark in poseLandmarkerResult.landmarks()) {
//                for (normalizedLandmark in landmark) {
//
//                    if (normalizedLandmark.visibility().get() >= 0.7f) {
//                        val x = normalizedLandmark.x() * imageWidth
//                        val y = normalizedLandmark.y() * imageHeight
//
//                        canvas.drawCircle(x, y, 8f, pointPaint)
//                    }
//                }
                drawLineLandmark(poseLandmarkerResult, canvas)
            }
        }

        canvas.restore()
    }

    private fun drawLineLandmark(poseLandmarkerResult: PoseLandmarkerResult, canvas: Canvas) {

        executeCheckExercise(exercise, poseLandmarkerResult).forEach {
            val exerciseInfoList = it.value
            val bodyA = exerciseInfoList[0] as List<Float>
            val bodyB = exerciseInfoList[1] as List<Float>
            val bodyC = exerciseInfoList[2] as List<Float>
            val bodyD = exerciseInfoList[3] as List<Float>
            val checkExercise = exerciseInfoList[5] as List<*>
            val isCheckExercise = checkExercise[0] as Boolean
            val code = checkExercise[1] as Int
            val exerciseRotation = exerciseInfoList[4] as Double

            if(isCheckExercise && code == 0) {
                canvas.drawLine(
                    bodyA[0] * imageWidth, bodyA[1] * imageHeight,
                    bodyB[0] * imageWidth, bodyB[1] * imageHeight,
                    lineCollectPaint)
                canvas.drawLine(
                    bodyB[0] * imageWidth, bodyB[1] * imageHeight,
                    bodyC[0] * imageWidth, bodyC[1] * imageHeight,
                    lineCollectPaint)
                canvas.drawLine(
                    bodyC[0] * imageWidth, bodyC[1] * imageHeight,
                    bodyD[0] * imageWidth, bodyD[1] * imageHeight,
                    lineCollectPaint)
            }else if (isCheckExercise && code == 1){
                canvas.drawLine(
                    bodyA[0] * imageWidth, bodyA[1] * imageHeight,
                    bodyB[0] * imageWidth, bodyB[1] * imageHeight,
                    lineWrongPaint)
                canvas.drawLine(
                    bodyB[0] * imageWidth, bodyB[1] * imageHeight,
                    bodyC[0] * imageWidth, bodyC[1] * imageHeight,
                    lineWrongPaint)
                canvas.drawLine(
                    bodyC[0] * imageWidth, bodyC[1] * imageHeight,
                    bodyD[0] * imageWidth, bodyD[1] * imageHeight,
                    lineWrongPaint)

            }
            drawRotation(canvas, exerciseRotation, bodyC)
        }
    }

    private fun drawRotation(canvas: Canvas, exerciseRotation: Double, bodyB:List<Float>) {
        canvas.save()

        canvas.rotate(
            -rotationDegrees.toFloat(),
            bodyB[0] * imageWidth,
            bodyB[1] * imageHeight
        )

        canvas.scale(
            -1f, 1f,
            bodyB[0] * imageWidth,
            bodyB[1] * imageHeight
        )

        canvas.drawText(
            "${exerciseRotation.toInt()}°",
            bodyB[0] * imageWidth,
            bodyB[1] * imageHeight,
            rotationPaint
        )

        canvas.restore()
    }
    fun setRotation(rotationDegreesValue: Int) {
        rotationDegrees = rotationDegreesValue
    }
    fun setLandmarkPoints(
        result: PoseLandmarkerResult,
        imageWidth: Int,
        imageHeight: Int,
        exercise: String,
        counter:Int
    ) {
        this.imageWidth = imageWidth
        this.imageHeight = imageHeight
        results = result
        this.exercise = exercise
        this.counter = counter.toString()

        when(rotationDegrees) {
            // 각 각도에 맞게 이미지 사이즈를 각 각도별로 위치를 맞춰 줌.
            90 -> scaleFactor =  max((width * 1f / imageHeight), (height * 1f / imageWidth))
            180 -> scaleFactor =  max((width * 1f / imageWidth), (height * 1f / imageHeight))
            270 -> scaleFactor =  max((width * 1f / imageHeight), (height * 1f / imageWidth))
            else -> scaleFactor =  max((width * 1f / imageWidth), (height * 1f / imageHeight))
        }
        // 초기화
        initPaints()
        // onDraw()를 호출하는 메소드
        invalidate()
    }

    private fun setCameraPoseMatrix(xOffset: Float, yOffset: Float) {
        matrix.reset()
        if (rotationDegrees != 0)
            matrix.postRotate(360f - rotationDegrees.toFloat(), imageWidth / 2f, imageHeight / 2f)

        when(rotationDegrees) {
            90 -> matrix.postScale(-1f, 1f, imageWidth / 2f, imageHeight / 2f)
            180 -> matrix.postScale(-1f, -1f, imageWidth / 2f, imageHeight / 2f)
            270 -> matrix.postScale(1f, -1f, imageWidth / 2f, imageHeight / 2f)
            else -> matrix.postScale(1f, 1f, imageWidth / 2f, imageHeight / 2f)
        }
        matrix.postScale(scaleFactor,scaleFactor)
        matrix.postTranslate(xOffset, yOffset) //preTranslate 이동후에 스케일이나 회전이 진행됨.
    }

    fun clear() {
        results = null
        pointPaint.reset()
        lineCollectPaint.reset()
        initPaints()
        invalidate()
    }

    companion object {
        private const val LANDMARK_STROKE_WIDTH = 5F
    }
}