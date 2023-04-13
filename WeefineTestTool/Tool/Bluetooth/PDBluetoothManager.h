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
/// 电池信息
@property (nonatomic, copy) void(^batteryCharacteristic)(NSInteger battery);
/// 当前点击按键
@property (nonatomic, copy) void(^buttonCharacteristic)(NSString *);
/// 传感器信息
@property (nonatomic, copy) void(^sensorCharacteristic)(float, float);
/// 硬件版本
@property (nonatomic, copy) void(^hardwareInformationCharacteristic)(NSString *hardware);
/// 软件版本
@property (nonatomic, copy) void(^softwareInformationCharacteristic)(NSString *software);
/// 固件版本
@property (nonatomic, copy) void(^firmwareInformationCharacteristic)(NSString *firmware);

+ (instancetype)shareInstance;

- (void)stopScan;

@end

NS_ASSUME_NONNULL_END
