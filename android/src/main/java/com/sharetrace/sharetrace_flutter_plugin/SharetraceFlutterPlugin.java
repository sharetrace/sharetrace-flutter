package com.sharetrace.sharetrace_flutter_plugin;

import android.app.Application;
import android.content.Context;
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
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * SharetraceFlutterPlugin
 */
public class SharetraceFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static final String TAG = "SharetraceFlutterPlugin";

    private static final String METHOD_GET_INSTALL_TRACE = "getInstallTrace";
    private static final String METHOD_REGISTER_WAKEUP = "registerWakeup";
    private static final String METHOD_INIT = "init";

    private MethodChannel channel;
    private boolean hasInited;
    private Intent cacheIntent;
    private FlutterPluginBinding cacheFlutterPluginBinding;

    private static final String KEY_CODE = "code";
    private static final String KEY_MSG = "msg";
    private static final String KEY_PARAMSDATA = "paramsData";
    private static final String KEY_CHANNEL = "channel";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        cacheFlutterPluginBinding = flutterPluginBinding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sharetrace_flutter_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equalsIgnoreCase(METHOD_GET_INSTALL_TRACE)) {
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
            }, defaultTimeout * 1000);
        } else if (call.method.equalsIgnoreCase(METHOD_REGISTER_WAKEUP)) {
            result.success("call registerWakeup success");
        } else if (call.method.equalsIgnoreCase(METHOD_INIT)) {
            init();
            result.success("call init success");
        } else {
            result.notImplemented();
        }
    }

    private void init() {
        if (cacheFlutterPluginBinding == null) {
            return;
        }
        hasInited = true;
        Context applicationContext = cacheFlutterPluginBinding.getApplicationContext();
        ShareTrace.init((Application) applicationContext);
        if (cacheIntent != null) {
            processWakeUp(cacheIntent);
            cacheIntent = null;
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

    private void wakeupResponse(Map<String, String> ret) {
        if (channel == null) {
            return;
        }
        channel.invokeMethod("onWakeupResponse", ret);
    }

    private void installResponse(Map<String, String> ret) {
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

    private void processWakeUp(Intent intent) {
        if (intent == null) {
            return;
        }

        if (!hasInited) {
            cacheIntent = intent;
            return;
        }

        ShareTrace.getWakeUpTrace(intent, new ShareTraceWakeUpListener() {
            @Override
            public void onWakeUp(AppData appData) {
                final Map<String, String> ret = parseToSuccessMap(appData);
                wakeupResponse(ret);
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        binding.addOnNewIntentListener(this);
        Intent intent = binding.getActivity().getIntent();
        processWakeUp(intent);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        binding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        processWakeUp(intent);
        return false;
    }
}
