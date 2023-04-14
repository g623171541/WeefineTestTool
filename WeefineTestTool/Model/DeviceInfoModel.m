//
//  DeviceInfoModel.m
//  WeefineTestTool
//
//  Created by paddy on 2023/3/31.
//

#import "DeviceInfoModel.h"

@implementation DeviceInfoModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
        [formatter setDateFormat:@"zzz yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        self.time = dateString;
    }
    return self;
}

@end
