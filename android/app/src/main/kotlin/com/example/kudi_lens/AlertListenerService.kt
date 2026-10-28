package com.example.kudi_lens

import android.app.Notification
import android.content.Context
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Watches posted notifications for bank and MoMo alerts (doc.md §17) and
 * queues them for the Flutter app. Only messages mentioning Ghana cedis are
 * kept, and only while the user has "Auto-track bank alerts" switched on.
 */
class AlertListenerService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName || !isTrackingEnabled()) return

        val notification = sbn.notification
        if (notification.flags and Notification.FLAG_GROUP_SUMMARY != 0) return

        val extras = notification.extras
        val message = latestMessage(extras) ?: return
        if (!CURRENCY.containsMatchIn(message)) return

        val sender = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: sbn.packageName
        AlertQueue.add(this, sender, message, sbn.packageName, sbn.postTime)
    }

    /** SMS apps using MessagingStyle carry the whole thread; take only the newest. */
    @Suppress("DEPRECATION")
    private fun latestMessage(extras: Bundle): String? {
        val thread = extras.getParcelableArray(Notification.EXTRA_MESSAGES)
        if (!thread.isNullOrEmpty()) {
            return (thread.last() as? Bundle)?.getCharSequence("text")?.toString()
        }
        return (extras.getCharSequence(Notification.EXTRA_BIG_TEXT)
            ?: extras.getCharSequence(Notification.EXTRA_TEXT))?.toString()
    }

    /** Mirrors the Flutter `auto_track_alerts` preference (opt-in, off by default). */
    private fun isTrackingEnabled() =
        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getBoolean("flutter.auto_track_alerts", false)

    companion object {
        private val CURRENCY = Regex("""\bGH(S|C|₵|¢)""", RegexOption.IGNORE_CASE)
    }
}
