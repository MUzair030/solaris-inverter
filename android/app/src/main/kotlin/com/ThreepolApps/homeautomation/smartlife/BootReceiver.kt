package com.ThreepolApps.homeautomation.smartlife

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import id.flutter.flutter_background_service.BackgroundService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val serviceIntent = Intent(context, BackgroundService::class.java)
            context.startForegroundService(serviceIntent)
        }
    }
}