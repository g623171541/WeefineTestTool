//
//  PDBluetoothManager.h
//  PhotoDive
//
//  Created by paddy on 2023/3/13.
//

#import <Foundation/Foundation.h>
#import "CommonDefines.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

// 大小端转换
#define Tranverse16(X)  ((((UInt16)(X) & 0xff00) >> 8) |(((UInt16)(X) & 0x00ff) << 8))
#define Tranverse32(X)  ((((UInt32)(X) & 0xff000000) >> 24) | (((UInt32)(X) & 0x00ff0000) >> 8) | (((UInt32)(X) & 0x0000ff00) << 8) | (((UInt32)(X) & 0x000000ff) << 24))
#define Tranverse64(X)  ((((UInt64)(X) & 0xff00000000000000) >> 56) | (((UInt64)(X) & 0x00ff000000000000) >> 40) | (((UInt64)(X) & 0x0000ff0000000000) >> 24) | (((UInt64)(X) & 0x000000ff00000000) >> 8) | (((UInt64)(X) & 0x00000000ff000000) << 8) | (((UInt64)(X) & 0x0000000000ff0000) << 24) | (((UInt64)(X) & 0x000000000000ff00) << 40) | (((UInt64)(X) & 0x00000000000000ff) << 56))

@interface PDBluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

/// 中央管理对象
@property (nonatomic, strong) CBCentralManager *centralManager;
/// 当前连接的外外设
@property (nonatomic, strong) CBPeripheral *peripheral;
/// 当前可连接的我的外围设备
@property (nonatomic, strong) NSMutableArray *myPeripherals;
/// 搜索到的我的外围设备
@property (nonatomic, strong) NSMutableArray *timerMyPeripherals;
/// 是否在连接状态
@property (nonatomic, assign) BOOL isConnectPeripheral;
/// 用于屏蔽刚连接后硬件的第一次按键数据
@property (nonatomic, assign) BOOL isFirstActionEvent;

#pragma mark - Block回调
/// 中央管理状态改变
@property (nonatomic, copy) void(^centralManagerUpdateState)(NSString *message);
/// 连接成功
@property (nonatomic, copy) void(^didConnectPeripheral)(NSString *peripheralName);
/// 连接断开
@property (nonatomic, copy) void(^didDisconnectPeripheral)(NSString *peripheralName);
/// 搜索到新外围
@property (nonatomic, copy) void(^discoverPeripheral)(NSArray *peripheralArr);
/// 制造商信息
@property (nonatomic, copy) void(^manufacturerInformationCharacteristic)(NSString *manufacturer);
/// 产品型号
@property (nonatomic, copy) void(^productModelCharacteristic)(NSString *product);
/// 电池信息
@property (nonatomic, copy) void(^batteryCharacteristic)(NSInteger battery);
/// 当前按键
@property (nonatomic, copy) void(^buttonCharacteristic)(int);
/// 硬件版本
@property (nonatomic, copy) void(^hardwareInformationCharacteristic)(NSString *hardware);
/// 软件版本
@property (nonatomic, copy) void(^softwareInformationCharacteristic)(NSString *software);
/// 固件版本
@property (nonatomic, copy) void(^firmwareInformationCharacteristic)(NSString *firmware);
/// 水压
@property (nonatomic, copy) void(^waterPressureCharacteristic)(float);
/// 温度
@property (nonatomic, copy) void(^temperatureCharacteristic)(float);
/// 气压
@property (nonatomic, copy) void(^gasPressureCharacteristic)(int);
/// 漏水
@property (nonatomic, copy) void(^leakCharacteristic)(BOOL);
/// 马达状态
/// 0x00    当前是初始状态（>90Kpa）
/// 0x01    当前马达已经被APP指令打开
/// 0x02    当前马达已经被APP指令关闭
/// 0x03    当前马达是正常抽气完成关闭
/// 0x04    当前马达打开超时(60S)关闭
@property (nonatomic, copy) void(^motorCharacteristic)(int);

+ (instancetype)shareInstance;
/// 销毁单例
+ (void)deleteInstance;
/// 重新开始扫描设备
- (void)restartScan;
/// 停止扫描
- (void)stopScan;

/// 读取传感器数据：水压、气压、温度
- (void)readSenseValue;
/// 开始漏水测试
- (void)startTestLeak;
/// 打开马达
/// - Parameter open: 打开还是关闭
- (void)openMotor:(BOOL )open;
/// 关机
- (void)shutdownDevice;

@end

NS_ASSUME_NONNULL_END
