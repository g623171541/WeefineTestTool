//
//  DeviceInfoModel.h
//  WeefineTestTool
//
//  Created by paddy on 2023/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoModel : NSObject

/// 连接时间
@property (nonatomic, strong) NSString *time;
/// 设备的mac地址
@property (nonatomic, strong) NSString *mac;
/// 蓝牙名称
@property (nonatomic, strong) NSString *name;
/// 软件版本
@property (nonatomic, strong) NSString *software;
/// 硬件版本
@property (nonatomic, strong) NSString *hardware;
/// 固件版本
@property (nonatomic, strong) NSString *firmware;
/// 产品型号
@property (nonatomic, strong) NSString *product;


/// 水压
@property (nonatomic, assign) NSInteger waterPressure;
/// 水温
@property (nonatomic, assign) CGFloat temperature;
/// 气压
@property (nonatomic, assign) NSInteger gasPressure;
/// 快门按键测试结果
@property (nonatomic, assign) BOOL shutter;
/// 上测试结果
@property (nonatomic, assign) BOOL up;
/// 下测试结果
@property (nonatomic, assign) BOOL down;
/// 左测试结果
@property (nonatomic, assign) BOOL left;
/// 右测试结果
@property (nonatomic, assign) BOOL right;
/// 漏水测试结果
@property (nonatomic, assign) BOOL leak;

/// 总的测试结果
@property (nonatomic, assign) BOOL result;











@end

NS_ASSUME_NONNULL_END
