import 'dart:async';

import 'package:flutter/services.dart';

class QiniuLive {
  static const MethodChannel _channel = const MethodChannel('qiniu_live');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String>  publishAudio(String url,String appId,String room,String token,Map<String,dynamic>userData,) async {
    final String result = await _channel.invokeMethod('publishAudio',{
      "url":url,
      "app_id":appId,
      "room":room,
      "token":token,
      "user_data":userData
    });
    return result;
  }

  static Future<Null>  unPublish() async {
    await _channel.invokeMethod('unPublish');
  }

    static Future<Null>  muteAudio(bool mute) async {
    await _channel.invokeMethod('muteAudio');
  }

    static Future<Null>  speakerOn(bool mute) async {
    await _channel.invokeMethod('speakerOn');
  }
}
