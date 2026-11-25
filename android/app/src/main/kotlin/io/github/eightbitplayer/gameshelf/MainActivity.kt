package io.github.eightbitplayer.gameshelf

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingPick: MethodChannel.Result? = null
    private var pendingExport: MethodChannel.Result? = null
    private var pendingExportSource: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickCoverImage" -> pickCoverImage(result)
                    "exportFile" -> exportFile(call.argument("path")!!, call.argument("fileName")!!, result)
                    "refreshWidgets" -> {
                        CoverWidgetProvider.refreshAll(applicationContext)
                        result.success(null)
                    }
                    "openLink" -> openLink(call.arguments as String, result)
                    "takeLaunchGameId" -> result.success(takeGameId(intent))
                    else -> result.notImplemented()
                }
            }
        }
    }

    /**
     * Apre un indirizzo con l'app che lo gestisce: un link di YouTube finisce
     * nell'app di YouTube se è installata — Android la riconosce perché il dominio
     * è verificato — altrimenti nel browser predefinito.
     *
     * Non è una chiamata di rete di GameShelf: l'indirizzo viene consegnato ad
     * Android, che se ne occupa. Per questo l'app non ha il permesso INTERNET.
     * Restituisce false se sul telefono non c'è niente che sappia aprirlo.
     */
    private fun openLink(url: String, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        takeGameId(intent)?.let { channel?.invokeMethod("openGame", it) }
    }

    /** Id del gioco da aprire se l'app è stata avviata dal widget; lo consuma una volta sola. */
    private fun takeGameId(intent: Intent?): Long? {
        if (intent == null || !intent.hasExtra(CoverWidgetProvider.EXTRA_GAME_ID)) return null
        val id = intent.getLongExtra(CoverWidgetProvider.EXTRA_GAME_ID, -1)
        intent.removeExtra(CoverWidgetProvider.EXTRA_GAME_ID)
        return id.takeIf { it > 0 }
    }

    /**
     * Selettore di file di sistema invece del selettore «Foto»: è l'unico che accetta una
     * posizione iniziale, quindi si riapre nella cartella dell'ultima copertina scelta.
     */
    private fun pickCoverImage(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("busy", "Selezione già in corso", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "image/*"
            val last = getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_LAST_COVER_URI, null)
            if (last != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(last))
            }
        }
        try {
            pendingPick = result
            startActivityForResult(intent, REQUEST_PICK_COVER)
        } catch (e: Exception) {
            pendingPick = null
            result.error("no_picker", e.message, null)
        }
    }

    /**
     * Salva un file già pronto dove sceglie l'utente, copiandolo a blocchi.
     *
     * Il selettore di Flutter vuole l'intero contenuto in memoria, e un backup con le
     * copertine supera abbondantemente i 100 MB: qui il file viene scritto in streaming,
     * quindi non c'è alcun limite di dimensione.
     */
    private fun exportFile(path: String, fileName: String, result: MethodChannel.Result) {
        if (pendingExport != null) {
            result.error("busy", "Esportazione già in corso", null)
            return
        }
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/zip"
            putExtra(Intent.EXTRA_TITLE, fileName)
            val last = getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY_LAST_BACKUP_URI, null)
            if (last != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(last))
            }
        }
        try {
            pendingExport = result
            pendingExportSource = path
            startActivityForResult(intent, REQUEST_EXPORT_FILE)
        } catch (e: Exception) {
            pendingExport = null
            pendingExportSource = null
            result.error("no_picker", e.message, null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_EXPORT_FILE) {
            val result = pendingExport ?: return
            val source = pendingExportSource
            pendingExport = null
            pendingExportSource = null
            val uri = data?.data
            if (resultCode != Activity.RESULT_OK || uri == null || source == null) {
                result.success(null)
                return
            }
            getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putString(KEY_LAST_BACKUP_URI, uri.toString()).apply()
            Thread {
                try {
                    contentResolver.openOutputStream(uri)?.use { output ->
                        File(source).inputStream().use { input -> input.copyTo(output, 1 shl 16) }
                    } ?: throw IllegalStateException("Destinazione non scrivibile")
                    runOnUiThread { result.success(uri.toString()) }
                } catch (e: Exception) {
                    runOnUiThread { result.error("write_failed", e.message, null) }
                }
            }.start()
            return
        }
        if (requestCode != REQUEST_PICK_COVER) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingPick ?: return
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(KEY_LAST_COVER_URI, uri.toString()).apply()

        // Le copie delle scelte precedenti non servono più.
        cacheDir.listFiles { file -> file.name.startsWith(PICK_PREFIX) }?.forEach { it.delete() }
        val target = File(cacheDir, "$PICK_PREFIX${System.currentTimeMillis()}.jpg")
        Thread {
            try {
                copyScaled(uri, target)
                runOnUiThread { result.success(target.path) }
            } catch (e: Exception) {
                runOnUiThread { result.error("read_failed", e.message, null) }
            }
        }.start()
    }

    /** Copia l'immagine scelta come JPEG, con il lato lungo al massimo di [MAX_SIDE] pixel. */
    private fun copyScaled(uri: Uri, target: File) {
        val bitmap: Bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // ImageDecoder applica da solo l'orientamento EXIF delle foto.
            ImageDecoder.decodeBitmap(ImageDecoder.createSource(contentResolver, uri)) { decoder, info, _ ->
                val width = info.size.width
                val height = info.size.height
                val scale = minOf(1.0, MAX_SIDE.toDouble() / maxOf(width, height))
                decoder.setTargetSize(maxOf(1, (width * scale).toInt()), maxOf(1, (height * scale).toInt()))
                decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
            }
        } else {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            contentResolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it, null, bounds) }
            var sample = 1
            while (maxOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= MAX_SIDE) sample *= 2
            contentResolver.openInputStream(uri)?.use {
                BitmapFactory.decodeStream(it, null, BitmapFactory.Options().apply { inSampleSize = sample })
            } ?: throw IllegalStateException("Immagine non leggibile")
        }
        FileOutputStream(target).use { bitmap.compress(Bitmap.CompressFormat.JPEG, 95, it) }
        bitmap.recycle()
    }

    companion object {
        private const val CHANNEL = "gameshelf/native"
        private const val REQUEST_PICK_COVER = 0x6D5
        private const val REQUEST_EXPORT_FILE = 0x6D6
        private const val PREFS = "gameshelf_native"
        private const val KEY_LAST_COVER_URI = "last_cover_uri"
        private const val KEY_LAST_BACKUP_URI = "last_backup_uri"
        private const val PICK_PREFIX = "copertina_scelta_"
        private const val MAX_SIDE = 1600
    }
}
