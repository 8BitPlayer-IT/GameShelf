package io.github.eightbitplayer.gameshelf

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import java.io.File

/**
 * Widget della schermata home: la copertina di un gioco della libreria scelto a caso, che
 * cambia ogni ora (updatePeriodMillis in cover_widget_info.xml).
 *
 * Legge direttamente il database dell'app in sola lettura, quindi è sempre allineato alla
 * libreria senza bisogno di sincronizzazioni. Toccandolo si apre la scheda del gioco.
 */
class CoverWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, appWidgetIds: IntArray) {
        update(context, manager, appWidgetIds, rotate = true)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        // Ridimensionamento: stessa copertina, solo ridisegnata.
        update(context, manager, intArrayOf(appWidgetId), rotate = false)
    }

    private class Cover(val gameId: Long, val title: String, val file: File)

    companion object {
        const val EXTRA_GAME_ID = "io.github.eightbitplayer.gameshelf.GAME_ID"
        private const val PREFS = "cover_widget"
        private const val KEY_LAST_ID = "last_game_id"
        private const val MAX_SIDE = 720

        /** Ridisegna i widget tenendo la copertina attuale, se il gioco esiste ancora. */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, CoverWidgetProvider::class.java))
            if (ids.isNotEmpty()) update(context, manager, ids, rotate = false)
        }

        private fun update(context: Context, manager: AppWidgetManager, ids: IntArray, rotate: Boolean) {
            val cover = pickCover(context, rotate)
            val bitmap = cover?.let { decodeScaled(it.file) }
            for (id in ids) manager.updateAppWidget(id, buildViews(context, cover, bitmap))
        }

        private fun pickCover(context: Context, rotate: Boolean): Cover? {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val lastId = prefs.getLong(KEY_LAST_ID, Long.MIN_VALUE)
            val covers = readCovers(context.getDir("flutter", Context.MODE_PRIVATE))
            if (covers.isEmpty()) return null
            val current = covers.firstOrNull { it.gameId == lastId }
            val chosen = if (!rotate && current != null) {
                current
            } else {
                // A caso, ma mai la stessa di prima se ce n'è più d'una.
                covers.filter { it.gameId != lastId }.ifEmpty { covers }.random()
            }
            prefs.edit().putLong(KEY_LAST_ID, chosen.gameId).apply()
            return chosen
        }

        private fun readCovers(documents: File): List<Cover> {
            val database = File(documents, "gameshelf.sqlite")
            try {
                if (database.exists()) {
                    SQLiteDatabase.openDatabase(database.path, null, SQLiteDatabase.OPEN_READONLY).use { db ->
                        db.rawQuery("SELECT id, title, cover_path FROM games WHERE cover_path IS NOT NULL", null)
                            .use { cursor ->
                                val covers = ArrayList<Cover>()
                                while (cursor.moveToNext()) {
                                    val file = File(documents, cursor.getString(2))
                                    if (file.exists()) covers.add(Cover(cursor.getLong(0), cursor.getString(1), file))
                                }
                                return covers
                            }
                    }
                }
            } catch (e: Exception) {
                // Database occupato, o SQLite di sistema troppo vecchio per lo schema (Android 11
                // non conosce le colonne generate): si ripiega sulle sole immagini, senza titolo.
            }
            val files = File(documents, "covers").listFiles { file -> file.extension.equals("jpg", true) }
            return files?.map { Cover(fileId(it), "", it) } ?: emptyList()
        }

        /** Id negativo e stabile per le copertine lette senza database: non aprono alcuna scheda. */
        private fun fileId(file: File): Long = -(file.name.hashCode().toLong() and 0x7FFFFFFF) - 1

        private fun decodeScaled(file: File): Bitmap? {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(file.path, bounds)
            if (bounds.outWidth <= 0) return null
            var sample = 1
            while (maxOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= MAX_SIDE) sample *= 2
            return BitmapFactory.decodeFile(
                file.path,
                BitmapFactory.Options().apply {
                    inSampleSize = sample
                    inPreferredConfig = Bitmap.Config.RGB_565
                },
            )
        }

        private fun buildViews(context: Context, cover: Cover?, bitmap: Bitmap?): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.cover_widget)
            if (cover == null || bitmap == null) {
                views.setViewVisibility(R.id.widget_cover, View.GONE)
                views.setViewVisibility(R.id.widget_title, View.GONE)
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                views.setViewVisibility(R.id.widget_cover, View.VISIBLE)
                views.setImageViewBitmap(R.id.widget_cover, bitmap)
                views.setContentDescription(R.id.widget_cover, cover.title)
                views.setTextViewText(R.id.widget_title, cover.title)
                views.setViewVisibility(R.id.widget_title, if (cover.title.isEmpty()) View.GONE else View.VISIBLE)
            }
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                if (cover != null && cover.gameId > 0) putExtra(EXTRA_GAME_ID, cover.gameId)
            }
            val pending = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            return views
        }
    }
}
