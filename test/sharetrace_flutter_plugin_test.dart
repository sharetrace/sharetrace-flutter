import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharetrace_flutter_plugin/sharetrace_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('sharetrace_flutter_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await (SharetraceFlutterPlugin as dynamic).platformVersion, '42');
  });
}
