package com.example.kudi_lens

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kudi_lens/alerts")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pendingAlerts" -> result.success(AlertQueue.peek(this))
                    "acknowledge" -> {
                        AlertQueue.remove(this, call.arguments as Int)
                        result.success(null)
                    }
                    "isListenerEnabled" -> result.success(isListenerEnabled())
                    "openListenerSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isListenerEnabled(): Boolean {
        val component = ComponentName(this, AlertListenerService::class.java).flattenToString()
        return Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
            ?.split(':')
            ?.contains(component) == true
    }
}
