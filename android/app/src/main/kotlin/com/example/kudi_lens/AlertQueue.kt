package com.example.kudi_lens

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * Raw alerts captured by [AlertListenerService] while the Flutter app isn't
 * running. Flutter reads them with [peek] and removes them with [remove] only
 * after they have been saved, so a crash mid-processing loses nothing.
 */
object AlertQueue {
    private const val PREFS = "kudi_lens_alert_queue"
    private const val KEY = "queue"
    private const val MAX_SIZE = 500

    @Synchronized
    fun add(context: Context, sender: String, message: String, packageName: String, receivedAt: Long) {
        val queue = read(context)
        queue.put(
            JSONObject()
                .put("sender", sender)
                .put("message", message)
                .put("packageName", packageName)
                .put("receivedAt", receivedAt)
        )
        // Drop the oldest entries if the app hasn't been opened for a long time.
        while (queue.length() > MAX_SIZE) queue.remove(0)
        write(context, queue)
    }

    @Synchronized
    fun peek(context: Context): List<Map<String, Any>> {
        val queue = read(context)
        return (0 until queue.length()).map { i ->
            val alert = queue.getJSONObject(i)
            mapOf(
                "sender" to alert.getString("sender"),
                "message" to alert.getString("message"),
                "packageName" to alert.getString("packageName"),
                "receivedAt" to alert.getLong("receivedAt"),
            )
        }
    }

    /** Removes the oldest [count] alerts, i.e. those returned by [peek]. */
    @Synchronized
    fun remove(context: Context, count: Int) {
        val queue = read(context)
        val remaining = JSONArray()
        for (i in count until queue.length()) remaining.put(queue.get(i))
        write(context, remaining)
    }

    private fun read(context: Context) = JSONArray(
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, "[]")
    )

    private fun write(context: Context, queue: JSONArray) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY, queue.toString())
            .commit()
    }
}
