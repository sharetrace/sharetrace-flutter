
import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> ResponseHandler(Map<String, String> data);

class SharetraceFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('sharetrace_flutter_plugin');

  static final SharetraceFlutterPlugin _instance = SharetraceFlutterPlugin._internal();
  SharetraceFlutterPlugin._internal() {
    _channel.setMethodCallHandler(_onMethodHandle);
  }
  factory SharetraceFlutterPlugin.getInstance() => _getInstance();

  static _getInstance() {
    return _instance;
  }

  late ResponseHandler _installRespHandler;
  late ResponseHandler _wakeupRespHandler;

  Future _onMethodHandle(MethodCall call) async {
    if (call.method == "onInstallResponse") {
      return _installRespHandler(call.arguments.cast<String, String>());
    } else if (call.method == "onWakeupResponse") {
      return _wakeupRespHandler(call.arguments.cast<String, String>());
    }
  }

  void registerWakeupHandler(ResponseHandler responseHandler) {
    _wakeupRespHandler = responseHandler;
    _channel.invokeMethod("registerWakeup");
  }

  void getInstallTrace(ResponseHandler responseHandler, [int timeoutSeconds = 10]) {
    var args = new Map();
    args["timeoutSeconds"] = timeoutSeconds.toString();
    this._installRespHandler = responseHandler;
    _channel.invokeMethod("getInstallTrace", args);
  }

  void init() {
    _channel.invokeMethod("init");
  }

  void disableClipboard() {
    _channel.invokeMethod("disableClipboard");
  }

}
