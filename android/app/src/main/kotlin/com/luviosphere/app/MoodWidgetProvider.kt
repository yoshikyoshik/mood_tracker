package com.luviosphere.app  // <--- HIER DEINEN PAKETNAMEN EINSETZEN!

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.app.PendingIntent
import android.content.Intent

class MoodWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                
                // 1. STREAK DATEN LADEN UND ANZEIGEN
                // Wir holen den Wert, den Flutter unter 'tv_streak_value' gespeichert hat
                val streakValue = widgetData.getString("tv_streak_value", "0")
                setTextViewText(R.id.tv_streak_value, streakValue)

                // 2. BUTTON KLICKBAR MACHEN (APP ÖFFNEN)
                val intent = Intent(context, MainActivity::class.java)
                intent.action = Intent.ACTION_MAIN
                intent.addCategory(Intent.CATEGORY_LAUNCHER)
                
                val pendingIntent = PendingIntent.getActivity(
                    context, 
                    0, 
                    intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                
                // Verknüpfe den Button (btn_checkin) mit dem Start der App
                setOnClickPendingIntent(R.id.btn_checkin, pendingIntent)
                
                // Optional: Auch Klick auf den Rest des Widgets öffnet die App
                // setOnClickPendingIntent(R.id.tv_title, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}