import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiniu_live/qiniu_live.dart';

void main() {
  const MethodChannel channel = MethodChannel('qiniu_live');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await QiniuLive.platformVersion, '42');
  });
}
