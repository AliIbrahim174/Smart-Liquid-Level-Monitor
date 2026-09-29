package com.example.liquid_monitor

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.util.Timer
import java.util.TimerTask

class LiquidMonitorService : Service() {

    private var timer: Timer? = null

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startForeground(900, createNotification())

        timer = Timer()
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                // Monitoring loop will be connected to ESP8266 API in the next patch.
            }
        }, 0, 5000)
    }

    private fun createChannel() {
        val channel = NotificationChannel(
            "liquid_monitor_native",
            "Liquid Monitoring",
            NotificationManager.IMPORTANCE_LOW
        )
        getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, "liquid_monitor_native")
            .setContentTitle("Liquid Monitor")
            .setContentText("Monitoring liquid levels")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        timer?.cancel()
        super.onDestroy()
    }
}
