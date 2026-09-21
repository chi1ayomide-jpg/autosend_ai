package com.custom.wabot

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class ExecutionService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("ExecutionService", "Background execution service running...")
        return START_STICKY
    }
}
