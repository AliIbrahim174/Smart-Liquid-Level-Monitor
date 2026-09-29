package com.example.liquid_monitor

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL
import java.util.Timer
import java.util.TimerTask

class LiquidMonitorService : Service() {

    private var timer: Timer? = null
    private val espUrl = "http://192.168.4.1/rooms"
    private val alertedRooms = mutableSetOf<String>()

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startForeground(900, createNotification())

        timer = Timer()
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                checkLiquidLevels()
            }
        }, 0, 5000)
    }

    private fun checkLiquidLevels() {
        try {
            val connection = URL(espUrl).openConnection() as HttpURLConnection
            connection.connectTimeout = 3000
            connection.readTimeout = 3000
            connection.requestMethod = "GET"

            val response = connection.inputStream.bufferedReader().readText()
            connection.disconnect()

            val rooms = JSONArray(response)

            for (i in 0 until rooms.length()) {
                val room = rooms.getJSONObject(i)
                val name = room.optString("name")
                val level = room.optInt("level", 100)
                val status = room.optString("status")

                if ((level <= 25 || status == "CRITICAL") && !alertedRooms.contains(name)) {
                    sendAlert(name, level, status)
                    alertedRooms.add(name)
                }

                if (level > 25 && status != "CRITICAL") {
                    alertedRooms.remove(name)
                }
            }
        } catch (_: Exception) {
        }
    }

    private fun sendAlert(name: String, level: Int, status: String) {
        val notification = NotificationCompat.Builder(this, "liquid_monitor_alerts")
            .setContentTitle("Liquid Level Alert")
            .setContentText("$name: $level% - $status")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        getSystemService(NotificationManager::class.java)
            .notify(name.hashCode(), notification)
    }

    private fun createChannel() {
        val manager = getSystemService(NotificationManager::class.java)

        manager.createNotificationChannel(
            NotificationChannel(
                "liquid_monitor_native",
                "Liquid Monitoring Service",
                NotificationManager.IMPORTANCE_LOW
            )
        )

        manager.createNotificationChannel(
            NotificationChannel(
                "liquid_monitor_alerts",
                "Liquid Alerts",
                NotificationManager.IMPORTANCE_HIGH
            )
        )
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
