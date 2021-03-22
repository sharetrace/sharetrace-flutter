
import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> ResponseHandler(Map<String, String> data);

class SharetraceFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('sharetrace_flutter_plugin');

  static SharetraceFlutterPlugin _instance;
  SharetraceFlutterPlugin._internal() {
    _channel.setMethodCallHandler(_onMethodHandle);
  }
  factory SharetraceFlutterPlugin.getInstance() => _getInstance();

  static _getInstance() {
    if (_instance == null) {
      _instance = SharetraceFlutterPlugin._internal();
    }
    return _instance;
  }

  Future defaultHandler() async {}

  ResponseHandler _installRespHandler;
  ResponseHandler _wakeupRespHandler;

  Future<Null> _onMethodHandle(MethodCall call) async {
    if (call.method == "onInstallResponse") {
      if (_installRespHandler != null) {
        return _installRespHandler(call.arguments.cast<String, String>());
      }
      return defaultHandler();
    } else if (call.method == "onWakeupResponse") {
      if (_wakeupRespHandler != null) {
        return _wakeupRespHandler(call.arguments.cast<String, String>());
      }
      return defaultHandler();
    }
  }

  void registerWakeupHandler(ResponseHandler responseHandler) {
    _wakeupRespHandler = responseHandler;
    _channel.invokeMethod("registerWakeup");
  }

  void getInstallTrace(ResponseHandler responseHandler) {
    var args = new Map();
    this._installRespHandler = responseHandler;
    _channel.invokeMethod("getInstallTrace", args);
  }

}
