package com.example.fitchecker.draw

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Typeface
import android.util.AttributeSet
import android.view.View
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import kotlin.math.max

class CountTextCanvasView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
): View(context, attrs, defStyleAttr) {

    private val textMatrix = Matrix()
    private var countPaint = Paint()
    private var rotationDegrees = 0
    private var imageWidth = 1
    private var imageHeight = 1
    private var scaleFactor: Float = 1f
    private var counter: Int = 0
    private var exercise: String = ""
    private var setNumber: Int = 0

    private fun initPaints() {
        countPaint.color = Color.WHITE
        countPaint.style = Paint.Style.FILL
        countPaint.strokeWidth = STROKE_WIDTH
        countPaint.textSize = 20f
        countPaint.apply {
            isAntiAlias = true
            typeface = Typeface.createFromAsset(context.assets, "fonts/cafe24ohsquare.ttf")
        }
        countPaint.setShadowLayer(
            10f, // 그림자의 반경
            5f, 5f, // x, y 방향 오프셋
            Color.BLACK // 그림자 색상
        )
    }

    fun setImageSizeAndCounter(
        imageWidth: Int,
        imageHeight: Int,
        exercise:String,
        counter: Int,
        setNumber: Int
    ) {
        this.imageWidth = imageWidth
        this.imageHeight = imageHeight
        this.counter = counter
        this.exercise = exercise
        this.setNumber = setNumber

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
    fun setRotation(
        rotation: Int
    ) {
        rotationDegrees = rotation
    }
    companion object {
        private const val STROKE_WIDTH = 5F
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.save()
        setTextMatrix()
        canvas.concat(textMatrix)
        canvas.drawText("세 트 : ${setNumber}", imageWidth * 0.57f , 0f, countPaint)
        canvas.drawText("카운트 : ${counter}", imageWidth * 0.55f , 40f, countPaint)

        canvas.restore()
    }

    private fun setTextMatrix() {
        textMatrix.reset()

        val xOffset = (width - imageWidth * scaleFactor) / 2f // 캔버스 중심으로 이동하기 위한 이동값
        val yOffset = (height - imageHeight * scaleFactor) / 2f //

        textMatrix.postScale(scaleFactor,scaleFactor)
        textMatrix.postTranslate(xOffset, yOffset) //preTranslate 이동후에 스케일이나 회전이 진행됨.
    }
}