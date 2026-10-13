package com.custom.wabot

import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class QuickTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val current = prefs.getBoolean("flutter.auto_reply_enabled", true)
        val newState = !current

        prefs.edit().putBoolean("flutter.auto_reply_enabled", newState).apply()
        Log.d("OmniFlowTile", "Toggled Auto-Reply via Quick Tile: $newState")

        updateTileState()
    }

    private fun updateTileState() {
        val tile = qsTile ?: return
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val isEnabled = prefs.getBoolean("flutter.auto_reply_enabled", true)

        tile.state = if (isEnabled) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = if (isEnabled) "OmniFlow: ON" else "OmniFlow: OFF"
        tile.updateTile()
    }
}
