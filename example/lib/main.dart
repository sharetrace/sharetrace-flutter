import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sharetrace_flutter_plugin/sharetrace_flutter_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result;
  SharetraceFlutterPlugin _sharetraceFlutterPlugin;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _sharetraceFlutterPlugin = SharetraceFlutterPlugin.getInstance();
    _sharetraceFlutterPlugin.registerWakeupHandler(wakeupHandler);

    setState(() {
      result = "";
    });
  }

  Future responseHandler(Map<String, String> data) async {
    setState(() {
      result = "getInstallTrace: \n\n"
           + "code= " + data['code'] + "\n"
           + "msg= " + data['msg'] + "\n"
           + "paramsData= " + data['paramsData'] + "\n"
           + "channel= " + data['channel'];
    });
  }

  Future wakeupHandler(Map<String, String> data) async {
    setState(() {
      result = "wakeupTrace: \n\n"
          + "code= " + data['code'] + "\n"
          + "msg= " + data['msg'] + "\n"
          + "paramsData= " + data['paramsData'] + "\n"
          + "channel= " + data['channel'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sharetrace Flutter Plugin Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(result, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              RaisedButton(
                onPressed: () {
                  _sharetraceFlutterPlugin.getInstallTrace(responseHandler);
                },
                child: Text('getInstallTrace', style: TextStyle(fontSize: 20)),
              )
            ],
          )
        ),
      ),
    );
  }
}
