package dev.articulate.articulate

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class DataFiles(private val activity: Activity, channel: MethodChannel) {
    private var pending: MethodChannel.Result? = null
    private val executor = Executors.newSingleThreadExecutor()
    private val cancelled = AtomicBoolean(false)
    private var copying = false
    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "chooseExport", "chooseImport" -> {
                    if (pending != null || copying) { result.error("busy", "A file operation is already active", null) }
                    else {
                        pending = result
                        val save = call.method == "chooseExport"
                        val intent = Intent(if (save) Intent.ACTION_CREATE_DOCUMENT else Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE); type = "application/octet-stream"
                            putExtra(Intent.EXTRA_LOCAL_ONLY, true)
                            if (save) putExtra(Intent.EXTRA_TITLE, call.arguments as? String ?: "Articulate.articulate")
                        }
                        try { activity.startActivityForResult(intent, 7191) }
                        catch (_: Exception) { pending = null; result.error("picker", "No document picker is available", null) }
                    }
                }
                "cancelCopy" -> { cancelled.set(true); result.success(null) }
                "readToPrivate", "writeFromPrivate" -> {
                    if (copying) { result.error("busy", "A file operation is already active", null) }
                    else {
                        val args = call.arguments as? Map<*, *>
                        val uri = (args?.get("uri") as? String)?.let { Uri.parse(it) }
                        val path = args?.get("path") as? String
                        val limit = (args?.get("limit") as? Number)?.toLong()
                        val save = call.method == "writeFromPrivate"
                        if (uri?.scheme != "content" || path == null || limit == null || limit < 0 || limit > 9L * 1024 * 1024 * 1024) {
                            result.error("storage", "Invalid document transfer", null)
                        } else {
                            copying = true; cancelled.set(false)
                            executor.execute {
                                try {
                                    val file = File(path).canonicalFile
                                    check(file.path.startsWith(activity.filesDir.canonicalPath + File.separator))
                                    check(file.name == (if (save) "library.articulate" else "incoming.articulate"))
                                    check(file.parentFile?.name?.matches(Regex("stage-[a-f0-9]{32}")) == true && file.parentFile?.parentFile?.name == "data-management")
                                    val digest = MessageDigest.getInstance("SHA-256")
                                    var total = 0L
                                    val input = if (save) file.inputStream() else activity.contentResolver.openInputStream(uri) ?: error("input")
                                    input.use { source ->
                                        val output = if (save) activity.contentResolver.openOutputStream(uri, "wt") ?: error("output") else file.outputStream()
                                        output.use { target ->
                                            val buffer = ByteArray(65536)
                                            while (true) {
                                                check(!cancelled.get()); val n = source.read(buffer); if (n < 0) break
                                                total += n; check(total <= limit); target.write(buffer, 0, n); digest.update(buffer, 0, n)
                                            }
                                            target.flush()
                                        }
                                    }
                                    if (save) {
                                        check(total == limit)
                                        val expected = args?.get("sha256") as? String ?: error("digest")
                                        check(digest.digest().joinToString("") { "%02x".format(it.toInt() and 0xff) } == expected)
                                        val verify = MessageDigest.getInstance("SHA-256"); var read = 0L
                                        activity.contentResolver.openInputStream(uri).use { source ->
                                            check(source != null); val buffer = ByteArray(65536)
                                            while (true) { check(!cancelled.get()); val n = source.read(buffer); if (n < 0) break; read += n; check(read <= limit); verify.update(buffer, 0, n) }
                                        }
                                        check(read == limit && verify.digest().joinToString("") { "%02x".format(it.toInt() and 0xff) } == expected)
                                    }
                                    activity.runOnUiThread { copying = false; result.success(null) }
                                } catch (_: Exception) {
                                    if (save) { try { DocumentsContract.deleteDocument(activity.contentResolver, uri) } catch (_: Exception) {} }
                                    activity.runOnUiThread { copying = false; result.error(if (cancelled.get()) "cancelled" else "storage", "Document transfer did not complete; a partial destination may remain", null) }
                                }
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    fun onResult(request: Int, code: Int, data: Intent?): Boolean {
        if (request != 7191) return false
        val result = pending; pending = null
        result?.success(if (code == Activity.RESULT_OK) data?.data?.toString() else null)
        return true
    }
}
