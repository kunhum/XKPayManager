//
//  SharedDelegate.h
//  XKPayManager
//
//  Created by Kenneth Tse on 2026/1/24.
//

#import <Foundation/Foundation.h>
#import <WechatOpenSDK/WXApi.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharedDelegate : NSObject <WXApiDelegate>

+ (instancetype)shared;

@property (copy, nonatomic) void(^respCallback)(BaseResp *resp);

@end

NS_ASSUME_NONNULL_END
