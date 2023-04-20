//
//  PDBluetoothManager.m
//  PhotoDive
//
//  Created by paddy on 2023/3/13.
//

#import "PDBluetoothManager.h"

@interface PDBluetoothManager ()
/// 需要过滤的蓝牙名字
@property (nonatomic, strong) NSArray *peripheralNameArr;
/// 定时器回调蓝牙外设
@property (nonatomic, strong) NSTimer *peripheralTimer;
/// 蓝牙广播数据长度，广播的数据是6字节的MAC地址
@property (nonatomic, assign) NSInteger advertisementDataLength;
/// 传感器特征数组，调用方法时读取其值
@property (nonatomic, strong) NSMutableArray *senseCharacterArrM;
/// 漏水检测特征
@property (nonatomic, strong) CBCharacteristic *leakCharacter;
/// 马达状态特征
@property (nonatomic, strong) CBCharacteristic *motorNotifyCharacter;
/// 马达控制特征
@property (nonatomic, strong) CBCharacteristic *motorWriteCharacter;
/// 关机特征
@property (nonatomic, strong) CBCharacteristic *shutdownCharacter;
@end

@implementation PDBluetoothManager

// !!!: 电池服务
static NSString * const BatteryServiceUUIDString = @"180F";
static NSString * const BatteryCharacteristicUUIDString = @"2A19";

// !!!: 设备信息的服务
static NSString * const DeviceInformationServiceUUIDString = @"180A";
// 制造商特征
static NSString * const ManufacturerInformationCharacteristicUUIDString = @"2A29";
// 产品型号
static NSString * const ProductModelCharacteristicUUIDString = @"2A24";
// 硬件版本特征
static NSString * const HardwareInformationCharacteristicUUIDString = @"2A27";
// 固件信息特征
static NSString * const FirmwareInformationCharacteristicUUIDString = @"2A26";
// 软件版本特征
static NSString * const SoftwareInformationCharacteristicUUIDString = @"2A28";

// !!!: 按键服务
static NSString * const ButtonServiceUUIDString = @"00001523-1212-EFDE-1523-785FEABCD123";
// 按键特征
static NSString * const ButtonCharacteristicUUIDString = @"00001524-1212-EFDE-1523-785FEABCD123";
// 关机特征
static NSString * const ShutdownCharacteristicUUIDString = @"00001525-1212-EFDE-1523-785FEABCD123";

// !!!: 传感器服务
static NSString * const SensorServiceUUIDString = @"00001623-1212-EFDE-1523-785FEABCD123";
// 水压特征
static NSString * const WaterPressureCharacteristicUUIDString = @"00001625-1212-EFDE-1523-785FEABCD123";
// 温度特征
static NSString * const TemperatureCharacteristicUUIDString = @"00001626-1212-EFDE-1523-785FEABCD123";
// 气压特征
static NSString * const GasPressureCharacteristicUUIDString = @"00001627-1212-EFDE-1523-785FEABCD123";
// 漏水上报特征
static NSString * const LeakCharacteristicUUIDString = @"00001628-1212-EFDE-1523-785FEABCD123";
// 马达状态特征
static NSString * const MotorNotifyCharacteristicUUIDString = @"00001629-1212-EFDE-1523-785FEABCD123";
// 马达控制特征 1字节 0x01启动抽气 0x00停止抽气
static NSString * const MotorWriteCharacteristicUUIDString = @"00001624-1212-EFDE-1523-785FEABCD123";

#pragma mark - BluetoothManager 单例
static PDBluetoothManager *instance = nil;
static dispatch_once_t token = 0;

+ (instancetype)shareInstance {
    dispatch_once(&token, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (void)deleteInstance {
    instance = nil;
    token = 0;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.peripheralNameArr = @[@"WEEFINE", @"HUISH", @"Kraken"];
        // 创建一个中央管理对象
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        // 初始化数组
        self.myPeripherals = @[].mutableCopy;
        self.timerMyPeripherals = @[].mutableCopy;
        // 定时器回调蓝牙外设
        self.peripheralTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanPeripheralsCallBack) userInfo:nil repeats:YES];
        self.advertisementDataLength = 6;
    }
    
    return self;
}

/// 定时1秒回调一次发现的蓝牙外设
- (void)scanPeripheralsCallBack {
    if (self.discoverPeripheral) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.discoverPeripheral(self.myPeripherals);
        });
    }
}
- (void)stopScan {
    [self.centralManager stopScan];
    [self.peripheralTimer setFireDate:[NSDate distantFuture]];
    self.peripheralTimer = nil;
}

/// 读取传感器数据：水压、气压、温度
- (void)readSenseValue {
    if (self.senseCharacterArrM.count == 3) {
        for (CBCharacteristic *character in self.senseCharacterArrM) {
            [self.peripheral readValueForCharacteristic:character];
        }
    }
}

/// 开始漏水测试
- (void)startTestLeak {
    // 监听漏水
    if (self.leakCharacter) {
        [self.peripheral setNotifyValue:YES forCharacteristic:self.leakCharacter];
    }
    // 监听马达
    if (self.motorNotifyCharacter) {
        [self.peripheral setNotifyValue:YES forCharacteristic:self.motorNotifyCharacter];
    }
}

/// 打开马达
/// - Parameter open: 打开还是关闭
- (void)openMotor:(BOOL )open {
    NSData *data = [[NSString stringWithFormat:@"%d", open] stringToData];
    [self.peripheral writeValue:data forCharacteristic:self.motorWriteCharacter type:CBCharacteristicWriteWithResponse];
}

/// 关机
- (void)shutdownDevice {
    NSData *data = [@"1" stringToData];
    [self.peripheral writeValue:data forCharacteristic:self.shutdownCharacter type:CBCharacteristicWriteWithResponse];
}

#pragma mark - 清除缓存数据
- (void)cleanData {
    self.myPeripherals = @[].mutableCopy;
    self.timerMyPeripherals = @[].mutableCopy;
}

#pragma mark - CBCentralManager 协议方法
#pragma mark 中央管理对象状态改变
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBManagerStatePoweredOn) {
        self.isConnectPeripheral = NO;
        [self cleanData];
    }
    NSString *message = @"";
    // 检查状态
    switch (central.state) {
        case CBManagerStateUnknown:
            message = NSLocalizedString(@"Bluetooth device is initialized.", nil);
            break;
        case CBManagerStateResetting:message = NSLocalizedString(@"Bluetooth devices do not support.", nil);
            break;
        case CBManagerStateUnsupported:message = NSLocalizedString(@"Bluetooth devices not authorized, please authorize in the set.", nil);
            break;
        case CBManagerStateUnauthorized:message = NSLocalizedString(@"Bluetooth devices not authorized, please authorize in the set.", nil);
            break;
        case CBManagerStatePoweredOff:message = NSLocalizedString(@"Has yet to open the bluetooth, open in the set, please.", nil);
            break;
        case CBManagerStatePoweredOn:
            // 扫描外围 第一个参数为nil表示扫任何外围
            [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
        default:
            // 中央管理对象状态改变
            NSLog(@"中央管理对象状态改变 默认状态");
            break;
    }
    
    if (self.centralManagerUpdateState && !isEmptyString(message)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.centralManagerUpdateState(message);
        });
    }
}

#pragma mark 搜索到外围
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 我的设备
    if ([self.peripheralNameArr containsObject:peripheral.name]) {
        NSData *advData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
        if (advData.length >= self.advertisementDataLength) {
            // MAC 6Bytes
            if (advData.length == 6) {
                peripheral.mac = [advData convertToHexStr];
            } else if (advData.length == 8) {
                peripheral.mac = [[advData subdataWithRange:NSMakeRange(2, 6)] convertToHexStr];
            }
        }
        
        if (![self.myPeripherals containsObject:peripheral]) {
            // 添加到我的外围设备显示数组
            [self.myPeripherals addObject:peripheral];
        }
        if (![self.timerMyPeripherals containsObject:peripheral]) {
            // 添加到我的外围数组
            [self.timerMyPeripherals addObject:peripheral];
        }
    }
}

#pragma mark 连接外围成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.isFirstActionEvent = YES;
    self.isConnectPeripheral = YES;
    [self cleanData];
    self.senseCharacterArrM = [NSMutableArray array];
    
    if (self.didConnectPeripheral) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didConnectPeripheral(peripheral.name);
        });
    }
    
    // 停止扫描
    [self.centralManager stopScan];
    // 设置外围委托代理
    self.peripheral = peripheral;
    [self.peripheral setDelegate:self];
    // 访问指定外围服务
    [self.peripheral discoverServices:nil];
    NSLog(@"连接外围成功 identifier:%@  名称:%@",[peripheral.identifier UUIDString],peripheral.name);
}

#pragma mark 连接外围失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"连接外围失败:%@",error);
}

#pragma mark 外围连接断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.isConnectPeripheral = NO;
    [self cleanData];
    
    if (self.didDisconnectPeripheral) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didDisconnectPeripheral(peripheral.name);
        });
    }
    NSLog(@"外围连接断开 identifier:%@  名称:%@",[peripheral.identifier UUIDString],peripheral.name);
}

#pragma mark - CBPeripheral 协议方法
#pragma mark 询问外围服务回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (error) {
        NSLog(@"错误服务:%@", [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        // 访问服务特征
        [self.peripheral discoverCharacteristics:nil forService:service];
        NSLog(@"发现服务:%@",[service.UUID UUIDString]);
    }
}

#pragma mark 访问服务特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSLog(@"错误特征:%@",[error localizedDescription]);
        return;
    }
    NSLog(@"服务：%@  特征集合：%@", service.UUID, service.characteristics);
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ManufacturerInformationCharacteristicUUIDString]]) {
            // 读取设备信息
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ProductModelCharacteristicUUIDString]]) {
            // 产品型号特征
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BatteryCharacteristicUUIDString]]) {
            // 监听电池信息特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ButtonCharacteristicUUIDString]]) {
            // 监听按键信息特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HardwareInformationCharacteristicUUIDString]]) {
            // 读取硬件信息
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FirmwareInformationCharacteristicUUIDString]]) {
            // 读取固件信息
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SoftwareInformationCharacteristicUUIDString]]) {
            // 读取软件信息
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WaterPressureCharacteristicUUIDString]]) {
            [self.senseCharacterArrM addObject:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GasPressureCharacteristicUUIDString]]) {
            [self.senseCharacterArrM addObject:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TemperatureCharacteristicUUIDString]]) {
            [self.senseCharacterArrM addObject:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:LeakCharacteristicUUIDString]]) {
            self.leakCharacter = characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MotorWriteCharacteristicUUIDString]]) {
            self.motorWriteCharacter = characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MotorNotifyCharacteristicUUIDString]]) {
            self.motorNotifyCharacter = characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ShutdownCharacteristicUUIDString]]) {
            self.shutdownCharacter = characteristic;
        }
        NSLog(@"发现特征:%@",characteristic);
    }
}

#pragma mark 获得外围特征值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"错误特征:%@",[error localizedDescription]);
        return;
    }
        
    // 制造商特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ManufacturerInformationCharacteristicUUIDString]]) {
        if (self.manufacturerInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                self.manufacturerInformationCharacteristic(manufacturer);
            });
        }
    }
    // 产品型号特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ProductModelCharacteristicUUIDString]]) {
        if (self.productModelCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *product = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                self.productModelCharacteristic(product);
            });
        }
    }
    
    // 电池信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BatteryCharacteristicUUIDString]]) {
        if (_batteryCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                u_long battery = strtoul([[NSString getStringFromHexByte:(Byte *)characteristic.value.bytes length:(int)characteristic.value.length] UTF8String], 0, 16);
                self.batteryCharacteristic(battery);
            });
        }
    }
    
    // 按键信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ButtonCharacteristicUUIDString]]) {
        int value = [characteristic.value convertToInt];
        if (self.buttonCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.buttonCharacteristic(value);
            });
        }
    }
    
    // 水压
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WaterPressureCharacteristicUUIDString]]) {
        int value = Tranverse32([characteristic.value convertToInt]);
        if (self.waterPressureCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.waterPressureCharacteristic(value/10.0);
            });
        }
    }
    // 气压
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GasPressureCharacteristicUUIDString]]) {
        int value = Tranverse32([characteristic.value convertToInt]);
        if (self.gasPressureCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gasPressureCharacteristic(value);
            });
        }
    }
    // 温度
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TemperatureCharacteristicUUIDString]]) {
        int value = Tranverse32([characteristic.value convertToInt]);
        if (self.temperatureCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.temperatureCharacteristic(value/100.0);
            });
        }
    }
    
    // 硬件信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HardwareInformationCharacteristicUUIDString]]) {
        NSString *hardware = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if (self.hardwareInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hardwareInformationCharacteristic(hardware);
            });
        }
    }
    
    // 软件信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SoftwareInformationCharacteristicUUIDString]]) {
        NSString *software = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if (self.softwareInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.softwareInformationCharacteristic(software);
            });
        }
    }
    
    // 固件信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FirmwareInformationCharacteristicUUIDString]]) {
        NSString *firmware = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if (self.firmwareInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.firmwareInformationCharacteristic(firmware);
            });
        }
    }
    
    // 漏水
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:LeakCharacteristicUUIDString]]) {
        if (self.leakCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.leakCharacteristic([characteristic.value convertToInt] != 0);
            });
        }
    }
    
    // 马达状态
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:MotorNotifyCharacteristicUUIDString]]) {
        if (self.motorCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.motorCharacteristic([characteristic.value convertToInt]);
            });
        }
    }
}

#pragma mark 发送数据到外围成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"发送数据到外围[%@] characteristic:%@, %@", error?@"❎":@"✅", characteristic.UUID, error ? [error localizedDescription] : characteristic.value);
}

#pragma mark 特征值更新通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"❌错误特征值改变:%@",error.localizedDescription);
    }
    // 通知已经开始
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];//读取
    } else {
        // 通知已经停止，断开外围
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

@end
