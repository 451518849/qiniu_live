//
//  Live.m
//
//  Created by 小发工作室 on 2019/7/21.
//

#import "Live.h"

@implementation Live

- (BOOL)isAdmin {
    if (_userData != nil) {
        if ([_userData[@"is_admin"] isEqual:@(1)]) {
            _isAdmin = true;
        }else {
            _isAdmin = false;
        }
    }
    return _isAdmin;
}

- (NSString *)userId {
    if (_userData != nil) {
        _userId = _userData[@"user_id"];
    }
    return _userId;
}

- (NSMutableArray<User *> *)users {
    if (_users == nil) {
        _users = [[NSMutableArray alloc] init];
    }
    return _users;
}

- (void)setLiveResult:(LiveResult)liveResult {
    _liveResult = liveResult;
}

- (void)removeUsers:(NSString *)userId {
    for (User *user in self.users) {
        if ([user.userId isEqualToString:userId]) {
            [self.users removeObject:user];
            self.flutterBlock([self.users copy]);
        }
    }
}

- (void)addUsers:(NSString *)userData {
    User *user = [User jsonToModel:userData];
    [self.users addObject:user];
    self.flutterBlock([self.users copy]);
}

- (void)setupEngine {
    self.engine = [[QNRTCEngine alloc] init];
    self.engine.delegate = self;
    self.engine.statisticInterval = 5;
}

- (void)publish {
    
}

- (void)unpublish {
    [self.engine unpublish];
}

- (void)requestToken {
    if ([self.token isEqualToString:@""]) {
        __weak typeof(self) wself = self;
        [QRDNetworkUtil requestTokenWithRoomName:self.roomName
                                           appId:self.appId
                                          userId:self.userId
                               completionHandler:^(NSError *error, NSString *token) {
                                   
                                   if (error) {
                                       NSLog(@"log:请求 token 出错，请检查网络 %@",error.description);
                                       wself.liveResult(@"网络请求错误");
                                   } else {
                                       NSString *str = [NSString stringWithFormat:@"获取到 token: %@", token];
                                       NSLog(@"log:%@",str);
                                       
                                       wself.token = token;
                                       [wself joinRTCRoom];
                                   }
                               }];
    }else {
        [self joinRTCRoom];
    }

}

- (void)joinRTCRoom {
    NSLog(@"加入房间token：%@",self.token);
    NSData * jsonData      = [NSJSONSerialization  dataWithJSONObject:self.userData
                                                              options:0
                                                                error:nil];
    NSString * userDataStr = [[NSString alloc] initWithData:jsonData
                                                   encoding:NSUTF8StringEncoding];
    [self.engine joinRoomWithToken:self.token userData:userDataStr];
}

/**
* SDK 运行过程中发生错误会通过该方法回调，具体错误码的含义可以见 QNTypeDefines.h 文件
*/
- (void)RTCEngine:(QNRTCEngine *)engine didFailWithError:(NSError *)error {
    NSString *str = [NSString stringWithFormat:@"SDK 运行过程中发生错误会通过该方法回调，具体错误码的含义可以见 QNTypeDefines.h 文件:\nerror: %@",  error];
    NSLog(@"log:%@",str);
}

/**
 * 房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可
 */
- (void)RTCEngine:(QNRTCEngine *)engine roomStateDidChange:(QNRoomState)roomState {
    
    NSDictionary *roomStateDictionary =  @{
                                           @(QNRoomStateIdle) : @"Idle",
                                           @(QNRoomStateConnecting) : @"Connecting",
                                           @(QNRoomStateConnected): @"Connected",
                                           @(QNRoomStateReconnecting) : @"Reconnecting",
                                           @(QNRoomStateReconnected) : @"Reconnected"
                                           };
    NSString *str = [NSString stringWithFormat:@"房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可:\nroomState: %@",  roomStateDictionary[@(roomState)]];
    NSLog(@"log:%@",str);
    
    
    if (QNRoomStateConnected == roomState) {
        NSLog(@"加入房间成功");
        // 加入房间成功
        if (self.isAdmin) {
            [self publish];
        }
    } else if (QNRoomStateIdle == roomState) {
        // 房间空闲
        NSLog(@"房间空闲");

    } else if (QNRoomStateReconnecting == roomState) {
        // 正在重连...
        NSLog(@"正在重连...");

    } else if (QNRoomStateReconnected == roomState) {
        // 重新加入房间成功
        NSLog(@"重新加入房间成功");

    }
    
}

/**
 * 本地音视频发布到服务器的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishLocalTracks:(NSArray<QNTrackInfo *> *)tracks {
    NSString *str = [NSString stringWithFormat:@"本地 Track 发布到服务器的回调:\n%@", tracks];
    NSLog(@"log:音视频发布成功了 %@",str);
}

/**
 * 远端用户加入房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didJoinOfRemoteUserId:(NSString *)userId userData:(NSString *)userData {
    NSString *str = [NSString stringWithFormat:@"远端用户加入房间的回调:\nuserId: %@, userData: %@",  userId, userData];
    NSLog(@"log:%@",str);

    if (![userId isEqualToString:@""] && ![userData isEqualToString:@""]) {
        NSDictionary *user = [User jsonToDic:userData];
        NSDictionary *info = @{
                               @"user":user,
                               @"op":@"join",
                               };
        self.flutterBlock(info);
    }

}

/**
 * 远端用户离开房间的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didLeaveOfRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 离开房间的回调", userId];
    NSLog(@"log:%@",str);
//    [self removeUsers:userId];
    
    NSDictionary *info = @{
                           @"user":@{@"user_id":userId},
                           @"op":@"leave",
                           };
    NSLog(@"info:%@",info);
    self.flutterBlock(info);
}

/**
 * 订阅远端用户成功的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didSubscribeTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"订阅远端用户: %@ 成功的回调:\nTracks: %@", userId, tracks];
    NSLog(@"log:%@",str);
}

/**
 * 远端用户发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 发布成功的回调:\nTracks: %@",  userId, tracks];
    NSLog(@"log:%@",str);
}

/**
 * 远端用户取消发布音/视频的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didUnPublishTracks:(NSArray<QNTrackInfo *> *)tracks ofRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 取消发布的回调:\nTracks: %@",  userId, tracks];
    NSLog(@"log:%@",str);
}

/**
 * 被 userId 踢出的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didKickoutByUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"被远端用户: %@ 踢出的回调",  userId];
    NSLog(@"log:%@",str);
}

/**
 * 远端用户音频状态变更为 muted 的回调
 */
- (void)RTCEngine:(QNRTCEngine *)engine didAudioMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 音频状态变更为: %d 的回调",  userId, trackId, muted];
    NSLog(@"log:%@",str);
}

// 去除与视频处理有关的直播协议

/**
 * 远端用户视频状态变更为 muted 的回调
 */
//- (void)RTCEngine:(QNRTCEngine *)engine didVideoMuted:(BOOL)muted ofTrackId:(NSString *)trackId byRemoteUserId:(NSString *)userId {
//    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频状态变更为: %d 的回调",  userId, trackId, muted];
//    NSLog(@"log:%@",str);
//}

/**
 * 远端用户视频首帧解码后的回调，如果需要渲染，则需要返回一个带 renderView 的 QNVideoRender 对象
 */
//- (QNVideoRender *)RTCEngine:(QNRTCEngine *)engine firstVideoDidDecodeOfTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
//    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频首帧解码后的回调",  userId, trackId];
//    NSLog(@"log:%@",str);
//
//    return nil;
//}

/**
 * 远端用户视频取消渲染到 renderView 上的回调
 */
//- (void)RTCEngine:(QNRTCEngine *)engine didDetachRenderView:(UIView *)renderView ofTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
//    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频取消渲染到 renderView 上的回调",  userId, trackId];
//    NSLog(@"log:%@",str);
//}

/**
 * 远端用户视频数据的回调
 *
 * 注意：回调远端用户视频数据会带来一定的性能消耗，如果没有相关需求，请不要实现该回调
 */
//- (void)RTCEngine:(QNRTCEngine *)engine didGetPixelBuffer:(CVPixelBufferRef)pixelBuffer ofTrackId:(NSString *)trackId remoteUserId:(NSString *)userId {
//    static int i = 0;
//    if (i % 300 == 0) {
//        NSString *str = [NSString stringWithFormat:@"远端用户视频数据的回调:\nuserId: %@ size: %zux%zu", userId, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer)];
//        //        [self addLogString:str];
//    }
//    i ++;
//
//}

/**
 * 远端用户音频数据的回调
 *
 * 注意：回调远端用户音频数据会带来一定的性能消耗，如果没有相关需求，请不要实现该回调
 */
//- (void)RTCEngine:(QNRTCEngine *)engine
//didGetAudioBuffer:(AudioBuffer *)audioBuffer
//    bitsPerSample:(NSUInteger)bitsPerSample
//       sampleRate:(NSUInteger)sampleRate
//        ofTrackId:(NSString *)trackId
//     remoteUserId:(NSString *)userId {
//    static int i = 0;
//    if (i % 500 == 0) {
//        NSString *str = [NSString stringWithFormat:@"远端用户音频数据的回调:\nuserId: %@\nbufferCount: %d\nbitsPerSample:%lu\nsampleRate:%lu,dataLen = %u",  userId, i, (unsigned long)bitsPerSample, (unsigned long)sampleRate, (unsigned int)audioBuffer->mDataByteSize];
//        //        [self addLogString:str];
//    }
//    i ++;
//}

/**
 * 获取到摄像头原数据时的回调, 便于开发者做滤镜等处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致编码帧率下降
 */
//- (void)RTCEngine:(QNRTCEngine *)engine cameraSourceDidGetSampleBuffer:(CMSampleBufferRef)sampleBuffer {
//    static int i = 0;
//    if (i % 300 == 0) {
//        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//        NSString *str = [NSString stringWithFormat:@"获取到摄像头原数据时的回调:\nbufferCount: %d, size = %zux%zu",  i, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer)];
//        //        [self addLogString:str];
//    }
//    i ++;
//}

/**
 * 获取到麦克风原数据时的回调，需要注意的是这个回调在 AU Remote IO 线程，请不要做过于耗时的操作，否则可能阻塞该线程影响音频输出或其他未知问题
 */
//- (void)RTCEngine:(QNRTCEngine *)engine microphoneSourceDidGetAudioBuffer:(AudioBuffer *)audioBuffer {
//    static int i = 0;
//    if (i % 500 == 0) {
//        NSString *str = [NSString stringWithFormat:@"获取到麦克风原数据时的回调:\nbufferCount: %d, dataLen = %u",  i, (unsigned int)audioBuffer->mDataByteSize];
//        //        [self addLogString:str];
//    }
//    i ++;
//}

/**
 *统计信息回调，回调的时间间隔由 statisticInterval 参数决定，statisticInterval 默认为 0，即不回调统计信息
 */
- (void)RTCEngine:(QNRTCEngine *)engine
  didGetStatistic:(NSDictionary *)statistic
        ofTrackId:(NSString *)trackId
           userId:(NSString *)userId {
    NSString *str = nil;
    if (statistic[QNStatisticAudioBitrateKey] && statistic[QNStatisticAudioPacketLossRateKey]) {
        int audioBitrate = [[statistic objectForKey:QNStatisticAudioBitrateKey] intValue];
        float audioPacketLossRate = [[statistic objectForKey:QNStatisticAudioPacketLossRateKey] floatValue];
        str = [NSString stringWithFormat:@"音频码率: %dbps\n音频丢包率：%3.1f%%\n", audioBitrate, audioPacketLossRate];
    }
    else {
        int videoBitrate = [[statistic objectForKey:QNStatisticVideoBitrateKey] intValue];
        float videoPacketLossRate = [[statistic objectForKey:QNStatisticVideoPacketLossRateKey] floatValue];
        int videoFrameRateKey = [[statistic objectForKey:QNStatisticVideoFrameRateKey] intValue];
        str = [NSString stringWithFormat:@"视频码率：%dbps\n视频丢包率：%3.1f%%\n视频帧率：%d", videoBitrate, videoPacketLossRate, videoFrameRateKey];
    }
    NSString *logStr = [NSString stringWithFormat:@"统计信息回调:userId: %@ trackId: %@\n%@", userId, trackId, str];
    NSLog(@"log:%@",str);
}


@end
