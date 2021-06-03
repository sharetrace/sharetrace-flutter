package com.sharetrace.sharetrace_flutter_plugin;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import cn.net.shoot.sharetracesdk.AppData;
import cn.net.shoot.sharetracesdk.ShareTrace;
import cn.net.shoot.sharetracesdk.ShareTraceInstallListener;
import cn.net.shoot.sharetracesdk.ShareTraceWakeUpListener;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SharetraceFlutterPlugin
 */
public class SharetraceFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static final String TAG = "SharetraceFlutterPlugin";
    private static MethodChannel channel;
    private static AppData cacheAppData = null;
    private static boolean hasWakeupRegisted = false;

    private static final String KEY_CODE = "code";
    private static final String KEY_MSG = "msg";
    private static final String KEY_PARAMSDATA = "paramsData";
    private static final String KEY_CHANNEL = "channel";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        FlutterEngine flutterEngine = flutterPluginBinding.getFlutterEngine();
        channel = new MethodChannel(flutterEngine.getDartExecutor(), "sharetrace_flutter_plugin");
        channel.setMethodCallHandler(this);
        ShareTrace.init((Application) flutterPluginBinding.getApplicationContext());
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
        channel = new MethodChannel(registrar.messenger(), "sharetrace_flutter_plugin");
        channel.setMethodCallHandler(new SharetraceFlutterPlugin());
        ShareTrace.init((Application) registrar.context());

        registrar.addNewIntentListener(newIntentListener);

        Activity activity = registrar.activity();
        if (activity != null) {
            ShareTrace.getWakeUpTrace(activity.getIntent(), shareTraceWakeUpListener);
        }
    }

    private static final PluginRegistry.NewIntentListener newIntentListener = new PluginRegistry.NewIntentListener() {
        @Override
        public boolean onNewIntent(Intent intent) {
            return ShareTrace.getWakeUpTrace(intent, shareTraceWakeUpListener);
        }
    };

    private static final ShareTraceWakeUpListener shareTraceWakeUpListener = new ShareTraceWakeUpListener() {
        @Override
        public void onWakeUp(AppData appData) {
            if (hasWakeupRegisted) {
                Map<String, String> ret = parseToSuccessMap(appData);
                wakeupResponse(ret);
                cacheAppData = null;
            } else {
                cacheAppData = appData;
            }
        }
    };

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getInstallTrace")) {
            result.success("call getInstallTrace success.");
            int defaultTimeout = 10;

            try {
                String timeoutSeconds = call.argument("timeoutSeconds");
                if (timeoutSeconds != null && !TextUtils.isEmpty(timeoutSeconds)) {
                    int timeout = Integer.parseInt(timeoutSeconds);
                    if (timeout > 0) {
                        defaultTimeout = timeout;
                    }
                }
            } catch (Throwable e) {
                // ignore
                Log.d(TAG, "timeoutSeconds parsed error: " + e.getMessage());
            }

            ShareTrace.getInstallTrace(new ShareTraceInstallListener() {
                @Override
                public void onInstall(AppData appData) {
                    if (appData == null) {
                        Map<String, String> ret = parseToResult(-1, "Extract data fail.", "", "");
                        installResponse(ret);
                        return;
                    }
                    Map<String, String> ret = parseToSuccessMap(appData);
                    installResponse(ret);
                }

                @Override
                public void onError(int code, String message) {
                    Map<String, String> ret = parseToResult(code, message, "", "");
                    installResponse(ret);
                }
            }, defaultTimeout);
        } else if (call.method.equals("registerWakeup")) {
            hasWakeupRegisted = true;
            if (cacheAppData != null) {
                Map<String, String> ret = parseToSuccessMap(cacheAppData);
                wakeupResponse(ret);
            }
            result.success("call registerWakeup success");
        } else {
            result.notImplemented();
        }
    }

    private static Map<String, String> parseToSuccessMap(AppData appData) {
        if (appData == null) {
            return new HashMap<>();
        }

        String paramsData = (appData.getParamsData() == null) ? "" : appData.getParamsData();
        String channel = (appData.getChannel() == null) ? "" : appData.getChannel();

        return parseToResult(200, "Success", paramsData, channel);
    }

    private static void wakeupResponse(Map<String, String> ret) {
        if (channel == null) {
            return;
        }
        channel.invokeMethod("onWakeupResponse", ret);
    }

    private static void installResponse(Map<String, String> ret) {
        if (channel == null) {
            return;
        }
        channel.invokeMethod("onInstallResponse", ret);
    }

    private static Map<String, String> parseToResult(int code, String msg, String paramsData, String channel) {
        Map<String, String> result = new HashMap<>();
        result.put(KEY_CODE, String.valueOf(code));
        result.put(KEY_MSG, msg);
        result.put(KEY_PARAMSDATA, paramsData);
        result.put(KEY_CHANNEL, channel);
        return result;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Intent intent = binding.getActivity().getIntent();
        if (intent != null) {
            ShareTrace.getWakeUpTrace(intent, shareTraceWakeUpListener);
        }

        binding.addOnNewIntentListener(newIntentListener);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
    }
}
