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
@end

@implementation PDBluetoothManager
// 服务
static NSString * const hrsServiceUUIDString = @"0000180D-0000-1000-8000-00805F9B34FB";
static NSString * const hrsSensorLocationCharacteristicUUIDString = @"00002A38-0000-1000-8000-00805F9B34FB";

// 设备信息的服务
static NSString * const DeviceInformationServiceUUIDString = @"180A";
// 制造商特征UUID
static NSString * const ManufacturerInformationCharacteristicUUIDString = @"2A29";
// 硬件版本
static NSString * const HardwareInformationCharacteristicUUIDString = @"2A27";
// 固件信息
static NSString * const FirmwareInformationCharacteristicUUIDString = @"2A26";
// 软件版本特征
static NSString * const SoftwareInformationCharacteristicUUIDString = @"2A19";

// 电池服务
static NSString * const BatteryServiceUUIDString = @"180F";
static NSString * const BatteryCharacteristicUUIDString = @"2A19";

// 按键服务
static NSString * const ButtonServiceUUIDString = @"00001523-1212-EFDE-1523-785FEABCD123";
static NSString * const ButtonCharacteristicUUIDString = @"00001524-1212-EFDE-1523-785FEABCD123";
// 传感器服务
static NSString * const SensorServiceUUIDString = @"00001623-1212-EFDE-1523-785FEABCD123";
static NSString * const SensorCharacteristicUUIDString = @"00001625-1212-EFDE-1523-785FEABCD123";

#pragma mark - BluetoothManager 单例
static PDBluetoothManager *instance = nil;
static dispatch_once_t token = 0;

+ (instancetype)shareInstance {
    dispatch_once(&token, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - 销毁单例
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
            peripheral.mac = [[advData subdataWithRange:NSMakeRange(0, 6)] convertToHexStr];
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
        NSLog(@"发现服务特征  UUID:%@",[service.UUID UUIDString]);
    }
}

#pragma mark 访问服务特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSLog(@"错误特征:%@",[error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ManufacturerInformationCharacteristicUUIDString]]) {
            // 读取设备信息
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BatteryCharacteristicUUIDString]]) {
            // 监听电池信息特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ButtonCharacteristicUUIDString]]) {
            // 监听按键信息特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SensorCharacteristicUUIDString]]) {
            // 监听传感器信息特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HardwareInformationCharacteristicUUIDString]]) {
            // 读取硬件信息
            [peripheral readValueForCharacteristic:characteristic];
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FirmwareInformationCharacteristicUUIDString]]) {
            // 读取固件信息
            [peripheral readValueForCharacteristic:characteristic];
        }
        NSLog(@"发现特征:%@  属性:%ld",[characteristic.UUID UUIDString],(unsigned long)characteristic.properties);
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
        return;
    }
    
    // 电池信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BatteryCharacteristicUUIDString]]) {
        if (_batteryCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                u_long battery = strtoul([[NSString getStringFromHexByte:(Byte *)characteristic.value.bytes length:(int)characteristic.value.length] UTF8String], 0, 16);
                self.batteryCharacteristic(battery);
            });
        }
        return;
    }
    
    // 按键信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ButtonCharacteristicUUIDString]]) {
        // 潜水设备静态按钮的按键值
        NSString *staticBtnTagStr = [NSString getStringFromHexByte:(Byte *)characteristic.value.bytes length:(int)characteristic.value.length].uppercaseString;
        NSLog(@"当前点击按键:%@",staticBtnTagStr);
        if (self.buttonCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.buttonCharacteristic(staticBtnTagStr);
            });
        }
        return;
    }
    
    // 传感器信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SensorCharacteristicUUIDString]]) {
        NSString *value = [NSString getStringFromHexByte:(Byte *)characteristic.value.bytes length:(int)characteristic.value.length].uppercaseString;
        NSString *oneByte = [value substringWithBeginByte:1 byte:1];
        NSString *twoByte = [value substringWithBeginByte:2 byte:1];
        NSString *threeByte = [value substringWithBeginByte:3 byte:1];
        NSString *fourByte = [value substringWithBeginByte:4 byte:1];
        if (self.sensorCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sensorCharacteristic((float)strtoul([[NSString stringWithFormat:@"%@%@",fourByte,threeByte] UTF8String], 0, 16) * 0.1, (float)strtoul([[NSString stringWithFormat:@"%@%@",twoByte,oneByte] UTF8String], 0, 16) * 0.1);
            });
        }
        return;
    }
    
    // 硬件信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HardwareInformationCharacteristicUUIDString]]) {
        NSString *hardware = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if (self.hardwareInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hardwareInformationCharacteristic(hardware);
            });
        }
        return;
    }
    
    // 软件信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SoftwareInformationCharacteristicUUIDString]]) {
        NSString *software = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if (self.softwareInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.softwareInformationCharacteristic(software);
            });
        }
        return;
    }
    
    // 固件信息特征值
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:FirmwareInformationCharacteristicUUIDString]]) {
        NSString *firmware = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        if (self.firmwareInformationCharacteristic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.firmwareInformationCharacteristic(firmware);
            });
        }
        return;
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
//        NSLog(@"通知已经开始：UUID:%@",[characteristic.UUID UUIDString]);
        [peripheral readValueForCharacteristic:characteristic];//读取
    } else {
        // 通知已经停止，断开外围
//        NSLog(@"通知已经停止：UUID:%@",[characteristic.UUID UUIDString]);
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

@end
