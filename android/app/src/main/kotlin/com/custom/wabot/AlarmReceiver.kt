package com.custom.wabot

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val phone = intent.getStringExtra("phone") ?: ""
        val message = intent.getStringExtra("message") ?: ""

        Log.d("WabotAlarm", "Alarm triggered for $phone: $message")

        // Prepare Accessibility service state
        WhatsAppAccessibilityAutomation.pendingMessage = message
        WhatsAppAccessibilityAutomation.isExecuting = true

        // Launch WhatsApp directly via API URI intent scheme
        val whatsappIntent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        try {
            context.startActivity(whatsappIntent)
        } catch (e: Exception) {
            Log.e("WabotAlarm", "Could not launch WhatsApp intent", e)
        }
    }
}
