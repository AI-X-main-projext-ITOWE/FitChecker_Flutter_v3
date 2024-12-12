package com.example.fitchecker.checkervoice
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.MediaPlayer
import android.util.Log

class SpeakManager {
    private lateinit var leftMediaPlayer: MediaPlayer
    private lateinit var rightMediaPlayer: MediaPlayer
    private lateinit var leftAssetFileDescriptor: AssetFileDescriptor
    private lateinit var rightAssetFileDescriptor: AssetFileDescriptor
    private val leftFileName = "voice/exerciseCall.m4a"
    private val rightFileName = "voice/exerciseCall.m4a"

    fun audioFromAssets(context: Context) {
        try {
            leftAssetFileDescriptor = context.assets.openFd(leftFileName)
            leftMediaPlayer = MediaPlayer().apply {
                setDataSource(
                    leftAssetFileDescriptor.fileDescriptor,
                    leftAssetFileDescriptor.startOffset,
                    leftAssetFileDescriptor.length
                )
                prepare()
                Log.d("SpeakManager", "leftMediaPlayer 준비 완료")
            }
            rightAssetFileDescriptor = context.assets.openFd(rightFileName)
            rightMediaPlayer = MediaPlayer().apply {
                setDataSource(
                    rightAssetFileDescriptor.fileDescriptor,
                    rightAssetFileDescriptor.startOffset,
                    rightAssetFileDescriptor.length
                )
                prepare()
                Log.d("SpeakManager", "rightMediaPlayer 준비 완료")
            }

        } catch (e: Exception) {
            Log.e("SpeakManager", "MediaPlayer 초기화 실패: ${e.message}")
        }
    }

    fun playAudio(side: String) {
        try {
            if (!leftMediaPlayer.isPlaying && !rightMediaPlayer.isPlaying) { // 재생 중인지 확인
                if (side == "left") {
                    leftMediaPlayer.seekTo(0)
                    leftMediaPlayer.start()
                    Log.d("MediaPlayer", "left 재생 시작")
                } else {
                    rightMediaPlayer.seekTo(0)
                    rightMediaPlayer.start()
                    Log.d("MediaPlayer", "right 재생 시작")
                }
            }
            else {
                Log.d("MediaPlayer", "이미 재생 중")
            }
        } catch (e: Exception) {
            Log.e("MediaPlayer", "MediaPlayer 재생 실패: ${e.message}")
        }

    }

    fun reset(side: String) {
        try {
            if (side == "left") {
                leftMediaPlayer.reset()
            }else {
                rightMediaPlayer.reset()
            }
        } catch (e: Exception) {
            Log.e("SpeakManager", "MediaPlayer 리셋 실패: ${e.message}")
        }
    }

    fun stopSpeak() {
        try {
            if (leftMediaPlayer.isPlaying) {
                leftMediaPlayer.stop()
            }
            else if (rightMediaPlayer.isPlaying)
                rightMediaPlayer.stop()
        } catch (e: Exception) {
            Log.e("SpeakManager", "재생 중지 실패: ${e.message}")
        }
    }

    fun cancel() {
        try {
            leftMediaPlayer.release()
            rightMediaPlayer.release()
        } catch (e: Exception) {
            Log.e("SpeakManager", "MediaPlayer 해제 실패: ${e.message}")
        }
    }
}

