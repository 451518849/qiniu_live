//
//  AudioLive.m
//  qiniu_live
//
//  Created by 小发工作室 on 2019/7/21.
//

#import "AudioLive.h"

static AudioLive *sharedObject = nil;

@implementation AudioLive

+ (instancetype)shareInstance{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedObject = [[AudioLive alloc] init];
    });
    return sharedObject;
}

- (void)publishAudio {
    
    [self setupEngine];
    [self requestToken];
}


- (void)publish {
    QNTrackInfo *audioTrack = [[QNTrackInfo alloc] initWithSourceType:QNRTCSourceTypeAudio master:YES];
    [self.engine publishTracks:@[audioTrack]];
}

@end
