package com.ThreepolApps.homeautomation.smartlife

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.threepol.inverter/wifi"
    private var wifiManager: WifiConnectionManager? = null

//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        createForegroundChannel()
//    }
//
//    private fun createForegroundChannel() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(
//                "foreground_service",
//                "Device Monitoring Service",
//                NotificationManager.IMPORTANCE_LOW // MUST NOT BE NONE
//            )
//            channel.description = "Keeps inverter monitoring alive"
//            channel.setSound(null, null)
//
//            val manager = getSystemService(NotificationManager::class.java)
//            manager.createNotificationChannel(channel)
//        }
//    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        wifiManager = WifiConnectionManager(applicationContext)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToWifi" -> {
                    val ssid = call.argument<String>("ssid")
                    val password = call.argument<String>("password") ?: ""
                    
                    if (ssid == null) {
                        result.error("INVALID_ARGUMENT", "SSID cannot be null", null)
                        return@setMethodCallHandler
                    }
                    
                    wifiManager?.connectToWifi(
                        ssid = ssid,
                        password = password,
                        onSuccess = { message ->
                            result.success(message)
                        },
                        onFailure = { error ->
                            result.error("CONNECTION_FAILED", error, null)
                        }
                    )
                }
                
                "disconnectWifi" -> {
                    wifiManager?.disconnectWifi()
                    result.success("Disconnected")
                }
                
                "getCurrentSSID" -> {
                    val ssid = wifiManager?.getCurrentSSID()
                    result.success(ssid)
                }
                
                "isConnected" -> {
                    val isConnected = wifiManager?.isConnected() ?: false
                    result.success(isConnected)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        // Don't automatically disconnect - let the app manage WiFi lifecycle
        // The network should stay connected even when activity is destroyed
        // wifiManager?.disconnectWifi()
        super.onDestroy()
    }
}
