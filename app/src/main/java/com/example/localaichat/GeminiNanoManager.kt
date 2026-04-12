package com.example.localaichat

import android.content.Context
import android.util.Log
import com.google.ai.edge.aicore.DownloadCallback
import com.google.ai.edge.aicore.DownloadConfig
import com.google.ai.edge.aicore.GenerativeAIException
import com.google.ai.edge.aicore.GenerativeModel
import com.google.ai.edge.aicore.generationConfig

class GeminiNanoManager(context: Context) {
    private val TAG = "GeminiNanoManager"

    private val downloadConfig = DownloadConfig(
        object : DownloadCallback {
            override fun onDownloadStarted(bytesToDownload: Long) {
                Log.d(TAG, "Download started: \$bytesToDownload bytes")
            }
            override fun onDownloadFailed(failureStatus: String, e: GenerativeAIException) {
                Log.e(TAG, "Download failed: \$failureStatus", e)
            }
            override fun onDownloadProgress(totalBytesDownloaded: Long) {
                Log.d(TAG, "Download progress: \$totalBytesDownloaded bytes")
            }
            override fun onDownloadCompleted() {
                Log.d(TAG, "Download completed")
            }
        }
    )

    private val model = GenerativeModel(
        generationConfig = generationConfig {
            this.context = context
            maxOutputTokens = 1000
            temperature = 0.7f
        },
        downloadConfig = downloadConfig
    )

    suspend fun checkIsReady(): Boolean {
        return try {
            model.prepareInferenceEngine()
            true
        } catch (e: Exception) {
            Log.e(TAG, "Model not ready: \${e.message}", e)
            false
        }
    }

    suspend fun generateContent(prompt: String): String {
        return try {
            val response = model.generateContent(prompt)
            response.text ?: "No response generated."
        } catch (e: Exception) {
            Log.e(TAG, "Error generating content: \${e.message}", e)
            val errorMessage = e.message ?: ""
            if (errorMessage.contains("BUSY")) {
                "Error: Model is busy. Please try again later."
            } else if (errorMessage.contains("NOT_FOUND")) {
                "Error: Model not found. Ensure AICore is updated."
            } else {
                "Error: \${e.localizedMessage}"
            }
        }
    }
}
