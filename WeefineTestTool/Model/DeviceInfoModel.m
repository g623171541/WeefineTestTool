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
        self.time = [self getTimeStr];
    }
    return self;
}

/// 重置
- (void)reset {
    self.manufacturer = @"";
    self.time = [self getTimeStr];
    self.mac = @"";
    self.name = @"";
    self.software = @"";
    self.hardware = @"";
    self.firmware = @"";
    self.product = @"";
    self.waterPressure = 0;
    self.temperature = 0;
    self.gasPressure = 0;
    self.shutter = @"";
    self.up = @"";
    self.down = @"";
    self.left = @"";
    self.right = @"";
    self.leak = @"";
    self.shutdown = @"";
    self.result = @"";
    self.deviceInfoResult = @"";
    self.senseInfoResult = @"";
}

- (NSString *)getTimeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"zzz yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

@end
