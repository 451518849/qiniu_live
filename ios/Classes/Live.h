//
//  Live.h
//
//  Created by 小发工作室 on 2019/7/21.
//
#import <Flutter/Flutter.h>

#import <QNRTCKit/QNRTCKit.h>
#import "QRDNetworkUtil.h"
#import "User.h"

typedef void (^LiveResult)(id _Nullable result);

@interface Live : NSObject<QNRTCEngineDelegate>

@property (nonatomic,copy   ) LiveResult       liveResult;

@property (nonatomic, strong) QNRTCEngine      *engine;
@property (nonatomic, copy  ) NSString         *token;
@property (nonatomic, copy  ) NSDictionary     *userData;//@{user_id,avatar_url,username,is_admin}
@property (nonatomic, copy  ) NSString         *appId;
@property (nonatomic, copy  ) NSString         *userId;
@property (nonatomic, copy  ) NSString         *roomName;
@property (nonatomic, assign) BOOL             isAdmin;

@property (nonatomic, strong) NSMutableArray<User*> *users;

@property (nonatomic, copy  ) FlutterEventSink flutterBlock;

- (void)setupEngine;
- (void)requestToken;
- (void)publish;
- (void)unpublish;

@end
