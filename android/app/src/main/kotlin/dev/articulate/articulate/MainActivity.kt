package dev.articulate.articulate

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.StatFs
import android.content.Intent

class MainActivity : FlutterActivity() {
    private var dataFiles: DataFiles? = null
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (dataFiles?.onResult(requestCode, resultCode, data) != true) super.onActivityResult(requestCode, resultCode, data)
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        dataFiles = DataFiles(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "articulate/data_files"))
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "articulate/audio_platform")
            .setMethodCallHandler { call, result ->
                if (call.method == "freeBytes") {
                    try {
                        result.success(StatFs(call.arguments as String).availableBytes)
                    } catch (e: Exception) {
                        result.error("storage", "Could not check available storage", null)
                    }
                } else result.notImplemented()
            }
    }
}
