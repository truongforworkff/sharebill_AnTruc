package com.antruc.sharebill_antruc

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "chung/receipt_ocr")
            .setMethodCallHandler { call, result ->
                if (call.method != "readText") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val bytes = call.arguments as? ByteArray
                if (bytes == null || bytes.isEmpty() || bytes.size > 2 * 1024 * 1024) {
                    result.error("invalid_image", "Invalid bill image", null)
                    return@setMethodCallHandler
                }
                var imageFile: File? = null
                val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                try {
                    val file = File.createTempFile("receipt_", ".img", cacheDir)
                    imageFile = file
                    file.writeBytes(bytes)
                    // File input preserves JPEG orientation metadata.
                    val image = InputImage.fromFilePath(this, Uri.fromFile(file))
                    recognizer.process(image)
                        .addOnSuccessListener { result.success(it.text) }
                        .addOnFailureListener { result.error("ocr_failed", "Cannot read bill", null) }
                        .addOnCompleteListener { recognizer.close(); file.delete() }
                } catch (_: Exception) {
                    recognizer.close()
                    imageFile?.delete()
                    result.error("ocr_failed", "Cannot read bill", null)
                }
            }
    }
}
