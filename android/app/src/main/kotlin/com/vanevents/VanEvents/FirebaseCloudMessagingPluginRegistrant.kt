package com.vanevents.VanEvents

import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin

object FirebaseCloudMessagingPluginRegistrant {
    fun registerWith(registry: PluginRegistry) {
        if (alreadyRegisteredWith(registry)) {
            return
        }
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
//        FlutterFirebaseFirestorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin"))
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