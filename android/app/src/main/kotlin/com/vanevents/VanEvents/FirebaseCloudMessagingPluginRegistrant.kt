package com.vanevents.VanEvents

import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import com.github.cloudwebrtc.flutter_callkeep.FlutterCallkeepPlugin
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin

object FirebaseCloudMessagingPluginRegistrant {
    fun registerWith(registry: PluginRegistry) {
        if (alreadyRegisteredWith(registry)) {
            return
        }
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
        FlutterFirebaseCorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"))
        FlutterFirebaseFirestorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin"))
        FlutterCallkeepPlugin.registerWith(registry.registrarFor("com.github.cloudwebrtc.flutter_callkeep.FlutterCallkeepPlugin"))
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))

    }

    private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
        val key: String? = FirebaseCloudMessagingPluginRegistrant::class.java.canonicalName
        if (registry.hasPlugin(key)) {
            return true
        }
        registry.registrarFor(key)
        return false
    }
}