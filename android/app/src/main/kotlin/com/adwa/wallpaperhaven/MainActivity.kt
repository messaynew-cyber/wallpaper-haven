package com.adwa.wallpaperhaven

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.adwa.wallpaperhaven/wallpaper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "setWallpaper") {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        try {
                            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
                            val bitmap = BitmapFactory.decodeFile(path)
                            wallpaperManager.setBitmap(bitmap)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("WALLPAPER_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
