package com.xiaofa.qiniu_live;

import android.content.Context;

import com.xiaofa.qiniu_live.live.AudioLive;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** QiniuLivePlugin */
public class QiniuLivePlugin implements MethodCallHandler {

//  public interface FlutterLiveCallback {
//    List getLiveUsers();
//
//  }
//  static FlutterLiveCallback flutterLiveCallback;

  private AudioLive audioLive;
  static Context context;

  static BinaryMessenger messenger;
  private EventChannel.EventSink eventCallback;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "qiniu_live");
    context = registrar.activeContext();
    messenger = registrar.messenger();
    channel.setMethodCallHandler(new QiniuLivePlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method){
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "publishAudio":
        setEventToFlutter();
        audioLive = AudioLive.getSingleton();
        audioLive.context = context;
        String token = call.argument("token");
        String room = call.argument("room");
        Map user_data = call.argument("user_data");
        String app_id = call.argument("app_id");
        audioLive.roomName = room;
        audioLive.appId = app_id;
        audioLive.userData = user_data;
        audioLive.roomToken = token;

        audioLive.publishAudio();

        audioLive.eventCallback = eventCallback;

        break;
      case "leaveRoom":
        audioLive.leaveRoom();
        break;
      case "unPublish":
        audioLive.unPublish();
        break;
      case "muteAudio":
        audioLive.onToggleMic();
        break;
      case "speakerOn":
        audioLive.onToggleSpeaker();
        break;
      default:
        result.notImplemented();
    }
  }


  void setEventToFlutter (){

    new EventChannel(messenger, "qiniu_live_users").setStreamHandler(
            new EventChannel.StreamHandler() {
              @Override
              // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
              public void onListen(Object arguments, EventChannel.EventSink events) {
                if (events != null){
                  eventCallback = events;
                }
              }

              @Override
              public void onCancel(Object arguments) {
                // 对面不再接收

              }
            }
    );
  }
}
