import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:qiniu_live/qiniu_live.dart';

class AudioPage extends StatefulWidget {
  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  static const EventChannel eventChannel =
      const EventChannel('qiniu_live_users');
  @override
  void initState() {
    super.initState();
    QiniuLive.publishAudio("d8lk7l4ed", "test","", {
      "user_id": "11",
      "avatar_url":
          "http://thirdqq.qlogo.cn/g?b=oidb&k=h22EA0NsicnjEqG4OEcqKyg&s=100",
      "username": "jason1",
      "is_admin": true
    });

    eventChannel
        .receiveBroadcastStream("")
        .listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object event) {

    print("qiniu_live_users:$event");
    setState(() {

    });
  }

  // 错误返回
  void _onError(Object error) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('音频直播'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('打开(关闭)扬声器'),
                onPressed: () {
                  QiniuLive.speakerOn();

                },
              ),
              FlatButton(
                child: Text('打开(关闭)声音'),
                onPressed: () {
                  QiniuLive.muteAudio();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
