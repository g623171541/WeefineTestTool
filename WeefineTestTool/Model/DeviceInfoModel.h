//
//  DeviceInfoModel.h
//  WeefineTestTool
//
//  Created by paddy on 2023/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 测试结果通过
#define kTestResultOK       @"OK"
// 测试结果不通过
#define kTestResultNC       @"NC"

@interface DeviceInfoModel : NSObject

/// 制造商
@property (nonatomic, strong) NSString *manufacturer;
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


/// 水压，收到的数据➗10，保留一位小数
@property (nonatomic, assign) CGFloat waterPressure;
/// 温度 需要/100保留两位
@property (nonatomic, assign) CGFloat temperature;
/// 气压
@property (nonatomic, assign) NSInteger gasPressure;
/// 快门按键测试结果
@property (nonatomic, strong) NSString *shutter;
/// 上测试结果
@property (nonatomic, strong) NSString *up;
/// 下测试结果
@property (nonatomic, strong) NSString *down;
/// 左测试结果
@property (nonatomic, strong) NSString *left;
/// 右测试结果
@property (nonatomic, strong) NSString *right;
/// 漏水测试结果
@property (nonatomic, strong) NSString *leak;

/// 总的测试结果
@property (nonatomic, strong) NSString *result;











@end

NS_ASSUME_NONNULL_END
