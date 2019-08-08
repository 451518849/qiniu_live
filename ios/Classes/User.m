//
//  User.m
//  qiniu_live
//
//  Created by 小发工作室 on 2019/7/21.
//

#import "User.h"

@implementation User

+ (User *)jsonToModel:(NSString *)jsonStr{
    NSData *data =[jsonStr dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    User *user      = [User new];
    user.userId     = json[@"user_id"];
    user.username   = json[@"username"];
    user.avatar_url = json[@"avatar_url"];
    user.is_admin   = json[@"is_admin"];

    return user;
}

+ (NSDictionary *)jsonToDic:(NSString *)jsonStr{
    if ([jsonStr isEqualToString:@""]) {
        return @{};
    }
    NSData *data =[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    return json;
}
@end
