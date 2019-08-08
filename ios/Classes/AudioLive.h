//
//  AudioLive.h
//  qiniu_live
//
//  Created by 小发工作室 on 2019/7/21.
//

#import "Live.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioLive : Live

@property (nonatomic, assign) BOOL isMute;

- (void)publishAudio;
+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
