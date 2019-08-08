//
//  User.h
//  qiniu_live
//
//  Created by 小发工作室 on 2019/7/21.
//

#import <Foundation/Foundation.h>


@interface User : NSObject

@property (nonatomic, copy  ) NSString     *userId;
@property (nonatomic, copy  ) NSString     *avatar_url;
@property (nonatomic, copy  ) NSString     *username;//@{user_id,avatar_url,username,is_admin}
@property (nonatomic, copy  ) NSString     *is_admin;

+ (User *)jsonToModel:(NSString *)jsonStr;
+ (NSDictionary *)jsonToDic:(NSString *)jsonStr;

@end
