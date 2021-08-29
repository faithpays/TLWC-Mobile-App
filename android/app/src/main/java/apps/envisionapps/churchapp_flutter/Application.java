package com.faithpays.tccedmonton;

import androidx.annotation.NonNull;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import com.tekartik.sqflite.SqflitePlugin;


public class Application extends FlutterApplication implements PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    }

}