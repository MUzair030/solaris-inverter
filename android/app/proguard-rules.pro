# Flutter Background Service
-keep class id.flutter.flutter_background_service.** { *; }
-keep interface id.flutter.flutter_background_service.** { *; }

# Keep Flutter Engine and Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class GeneratedPluginRegistrant { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# SharedPreferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Use legacy multidex if needed (already enabled in build.gradle)
-keep class androidx.multidex.** { *; }

# Dio / OkHttp / Networking
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class com.ThreepolApps.homeautomation.smartlife.core.network.** { *; }
-keepattributes Signature
-keepattributes AnnotationDefault
-keepattributes *Annotation*

# Prevent obfuscation of specific classes called via reflection or method channels
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep specific models if they are being serialized/deserialized via reflection
-keep class com.ThreepolApps.homeautomation.smartlife.models.** { *; }

# KEEP THE ENTIRE APP PACKAGE TO PREVENT STRIPPING OF MODELS/LOGIC
-keep class com.ThreepolApps.homeautomation.smartlife.** { *; }

# Add specific rules for any other plugins that might fail in release mode
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.it_nomads.flutter_network_interface.** { *; }
-keep class com.lyokone.location.** { *; }
-keep class com.sidlatau.flutter_barcode_scanner.** { *; }
