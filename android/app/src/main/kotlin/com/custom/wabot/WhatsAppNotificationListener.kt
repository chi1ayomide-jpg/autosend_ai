package com.custom.wabot

import android.app.Notification
import android.app.RemoteInput
import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

class WhatsAppNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        val pkg = sbn.packageName
        if (pkg != "com.whatsapp" && pkg != "com.whatsapp.w4b") return

        val extras = sbn.notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE) ?: return
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: return

        Log.d("WabotNotification", "Received notification from $title: $text")

        // Async AI & Auto-Reply execution
        thread {
            processAutoReply(sbn, title, text)
        }
    }

    private fun processAutoReply(sbn: StatusBarNotification, sender: String, incomingText: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val autoReplyEnabled = prefs.getBoolean("flutter.auto_reply_enabled", true)
        if (!autoReplyEnabled) return

        val apiKey = prefs.getString("flutter.gemini_api_key", "") ?: ""
        var replyMessage = "Hello $sender! AutoSend AI received: $incomingText"

        if (apiKey.isNotEmpty()) {
            val aiResponse = callGeminiAI(apiKey, incomingText)
            if (aiResponse.isNotEmpty()) {
                replyMessage = aiResponse
            }
        }

        // Direct Reply via Android Notification RemoteInput Action
        val wearableExtender = Notification.WearableExtender(sbn.notification)
        for (action in wearableExtender.actions) {
            val remoteInputs = action.remoteInputs ?: continue
            for (remoteInput in remoteInputs) {
                if (remoteInput.resultKey.lowercase().contains("reply") || remoteInput.resultKey.isNotEmpty()) {
                    val intent = Intent()
                    val bundle = Bundle()
                    bundle.putCharSequence(remoteInput.resultKey, replyMessage)
                    RemoteInput.addResultsToIntent(arrayOf(remoteInput), intent, bundle)

                    try {
                        action.actionIntent.send(applicationContext, 0, intent)
                        Log.d("WabotNotification", "Sent inline reply: $replyMessage")
                    } catch (e: Exception) {
                        Log.e("WabotNotification", "Failed to send inline reply", e)
                    }
                    return
                }
            }
        }
    }

    private fun callGeminiAI(apiKey: String, prompt: String): String {
        return try {
            val url = URL("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey")
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true

            val jsonBody = JSONObject().apply {
                put("contents", JSONArray().apply {
                    put(JSONObject().apply {
                        put("parts", JSONArray().apply {
                            put(JSONObject().apply {
                                put("text", "You are an automated assistant replying to WhatsApp chats. Concise reply to: $prompt")
                            })
                        })
                    })
                })
            }

            val writer = OutputStreamWriter(conn.outputStream)
            writer.write(jsonBody.toString())
            writer.flush()

            if (conn.responseCode == 200) {
                val responseText = conn.inputStream.bufferedReader().use { it.readText() }
                val responseJson = JSONObject(responseText)
                val candidates = responseJson.getJSONArray("candidates")
                if (candidates.length() > 0) {
                    val parts = candidates.getJSONObject(0).getJSONObject("content").getJSONArray("parts")
                    return parts.getJSONObject(0).getString("text").trim()
                }
            }
            ""
        } catch (e: Exception) {
            Log.e("WabotNotification", "Gemini API Call error", e)
            ""
        }
    }
}
