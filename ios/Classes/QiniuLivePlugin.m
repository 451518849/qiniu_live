#import "QiniuLivePlugin.h"
#import "AudioLive.h"

static NSObject<FlutterBinaryMessenger>* messager = nil;

@interface QiniuLivePlugin()

@property (nonatomic,strong) AudioLive *audioLive;

@end

@implementation QiniuLivePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    messager = [registrar messenger];
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"qiniu_live"
            binaryMessenger:[registrar messenger]];
  QiniuLivePlugin* instance = [[QiniuLivePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS" stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else if([@"publishAudio" isEqualToString:call.method]){
      
      NSString* token         = call.arguments[@"token"];
      NSString* url           = call.arguments[@"url"];
      NSString* roomName      = call.arguments[@"room"];
      NSDictionary* userData  = call.arguments[@"user_data"];
      NSString* appId         = call.arguments[@"app_id"];

      self.audioLive          = [AudioLive shareInstance];
      self.audioLive.userData = userData;
      self.audioLive.appId    = appId;
      self.audioLive.roomName = roomName;
      self.audioLive.url      = url;
      self.audioLive.token    = token;
      
      [self.audioLive publishAudio];
    
      [self listenUserEvent];
  }
  else if([@"leaveRoom" isEqualToString:call.method]){
      self.audioLive          = [AudioLive shareInstance];
      [self.audioLive.engine leaveRoom];
  }  else if([@"unpublish" isEqualToString:call.method]){
      self.audioLive = [AudioLive shareInstance];
      [self.audioLive unpublish];
  }
  else if([@"muteAudio" isEqualToString:call.method]){
      self.audioLive = [AudioLive shareInstance];
      [self.audioLive.engine muteAudio:!self.audioLive.isMute];
      self.audioLive.isMute = !self.audioLive.isMute;
  }
  else if([@"speakerOn" isEqualToString:call.method]){
      self.audioLive = [AudioLive shareInstance];
      self.audioLive.engine.muteSpeaker = !self.audioLive.engine.isMuteSpeaker;
  }
  else {
    result(FlutterMethodNotImplemented);
  }
    
}

- (void)listenUserEvent {
    
    NSString *channelName = @"qiniu_live_users";
    FlutterEventChannel *evenChannal = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:messager];
    
    [evenChannal setStreamHandler:self];
    
    NSLog(@"channelName:%@",channelName);
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events{
    if (events) {
        self.audioLive.flutterBlock = events;
    }
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
    return nil;
}

@end
