//
//  SharedDelegate.m
//  XKPayManager
//
//  Created by Kenneth Tse on 2026/1/24.
//

#import "SharedDelegate.h"

@implementation SharedDelegate

+ (instancetype)shared {
    static SharedDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)onResp:(BaseResp *)resp {
    if (self.respCallback) {
        self.respCallback(resp);
    }
}

@end
