package com.hufsm.sixsense.tacsflutter;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * TacsflutterPlugin
 */
public class TacsflutterPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    TacsManager tacsManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "tacsflutter");
        channel.setMethodCallHandler(this);
        this.tacsManager = new TacsManager();
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "tacsflutter");
        channel.setMethodCallHandler(new TacsflutterPlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "buildKeyring":
                tacsManager.buildKeyring();
                break;
            case "connect":
                tacsManager.connect();
                break;
            case "disconnect":
                tacsManager.disconnect();
                break;
            case "lock":
                tacsManager.lockDoors();
                break;
            case "unlock":
                tacsManager.unlockDoors();
                break;
            case "enableEngine":
                tacsManager.enableEngine();
                break;
            case "disableEngine":
                tacsManager.disableEngine();
                break;
            case "location":
                tacsManager.getLocation();
                break;
            case "telematics":
                tacsManager.getTelematics();
                break;
            default:
                break;
        }
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("buildKeyring")) {
            result.success("Keyring");
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
