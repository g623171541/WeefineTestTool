//
//  QCViewController.m
//  WeefineQC
//
//  Created by paddy on 2023/6/18.
//

#import "QCViewController.h"

typedef NS_ENUM(NSUInteger, PDPhysicalButtonType) {
    PDPhysicalButtonTypeLeftShort       =   0x10,   // 左-短按
    PDPhysicalButtonTypeLeftLong        =   0x11,   // 左-长按
    PDPhysicalButtonTypeShutterShort    =   0x20,   // 快门-短按
    PDPhysicalButtonTypeShutterLong     =   0x21,   // 快门-长按
    PDPhysicalButtonTypeRightShort      =   0x30,   // 右-短按
    PDPhysicalButtonTypeRightLong       =   0x31,   // 右-长按
    PDPhysicalButtonTypeUpShort         =   0x40,   // 上-短按
    PDPhysicalButtonTypeUpLong          =   0x41,   // 上-长按
    PDPhysicalButtonTypeDownShort       =   0x50,   // 下-短按
    PDPhysicalButtonTypeDownLong        =   0x51,   // 下-长按
};

@interface QCViewController ()
/// 设备测试模型
@property (nonatomic, strong) DeviceInfoModel *deviceInfoModel;
/// 蓝牙外设设备列表
@property (nonatomic, strong) NSMutableArray <CBPeripheral *>*peripheralArrM;
/// 短按【快门】按键次数
@property (nonatomic, assign) NSInteger shutterShortPressTimes;
/// 长按【快门】按键次数
@property (nonatomic, assign) NSInteger shutterLongPressTimes;
/// 短按【上】按键次数
@property (nonatomic, assign) NSInteger upShortPressTimes;
/// 长按【上】按键次数
@property (nonatomic, assign) NSInteger upLongPressTimes;
/// 短按【下】按键次数
@property (nonatomic, assign) NSInteger downShortPressTimes;
/// 长按【下】按键次数
@property (nonatomic, assign) NSInteger downLongPressTimes;
/// 短按【左】按键次数
@property (nonatomic, assign) NSInteger leftShortPressTimes;
/// 长按【左】按键次数
@property (nonatomic, assign) NSInteger leftLongPressTimes;
/// 短按【右】按键次数
@property (nonatomic, assign) NSInteger rightShortPressTimes;
/// 长按【右】按键次数
@property (nonatomic, assign) NSInteger rightLongPressTimes;

/// 漏水测试结果，0代表不漏水，1代表漏水 空的代表未检测
@property (nonatomic, strong) NSString *leakResultStr;
/// 马达测试结果
@property (nonatomic, strong) NSString *motorResultStr;
@end

@implementation QCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化数据
    [self initData];
    [self setupData];
    // 添加观察者
    [self addObserver];
    // 加载蓝牙模块
    [self loadBluetoothManager];
}

/// 初始化数据
- (void)initData {
    self.deviceInfoModel = [[DeviceInfoModel alloc] init];
}

- (void)setupData {
    [self.deviceInfoModel reset];
    self.shutterShortPressTimes = 0;
    self.shutterLongPressTimes = 0;
    self.upShortPressTimes = 0;
    self.upLongPressTimes = 0;
    self.downShortPressTimes = 0;
    self.downLongPressTimes = 0;
    self.leftShortPressTimes = 0;
    self.leftLongPressTimes = 0;
    self.rightShortPressTimes = 0;
    self.rightLongPressTimes = 0;
}

/// 确实发现外设
/// - Parameter peripheralArr: 外设数组
- (void)didFindPeripherals:(NSArray <CBPeripheral *>*)peripheralArr {
    BOOL isEqual = NO;
    // 创建俩新的数组
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:self.peripheralArrM];
    NSMutableArray *newArr = [NSMutableArray arrayWithArray:peripheralArr];
    [oldArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return obj1 > obj2;
    }];
    [newArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return obj1 > obj2;
    }];
    
    if (newArr.count == oldArr.count) {
        isEqual = YES;
        for (int i = 0; i < oldArr.count; i++) {
            if (![oldArr[i] isEqual:newArr[i]]) {
                isEqual = NO;
                break;
            }
        }
    }
    if (!isEqual) {
        self.peripheralArrM = [NSMutableArray arrayWithArray:peripheralArr];
        [self.tableView reloadData];
    }
}


#pragma mark - 载入蓝牙管理模块
- (void)loadBluetoothManager {
    @weakify(self);
    // !!!: 中央管理状态改变
    [PDBluetoothManager shareInstance].centralManagerUpdateState = ^(NSString *message) {
        [MBProgressHUD showMessage:message];
    };
    
    // !!!: 搜索到新外围回调
    [PDBluetoothManager shareInstance].discoverPeripheral = ^(NSArray <CBPeripheral *>*peripheralArr) {
        NSLog(@"外设：%@", peripheralArr);
        [self didFindPeripherals:peripheralArr];
    };
    
    // !!!: 连接成功
    [PDBluetoothManager shareInstance].didConnectPeripheral = ^(NSString *name) {
        @strongify(self);
        NSLog(@"蓝牙名称：%@", name);
        self.deviceInfoModel.name = name;
        self.deviceInfoModel.mac = [PDBluetoothManager shareInstance].peripheral.mac;
    };
    
    // !!!: 连接断开
    [PDBluetoothManager shareInstance].didDisconnectPeripheral = ^(NSString *name) {
        @strongify(self);
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@：%@",LocalizedString(@"连接已断开"), name]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupData];
            [PDBluetoothManager deleteInstance];
            [self loadBluetoothManager];
        });
    };
    
    // !!!: 按键信息回调
    [PDBluetoothManager shareInstance].buttonCharacteristic = ^(int value) {
        NSLog(@"按下了按键-【按键编号:%x】", value);
        @strongify(self);
        if (value == PDPhysicalButtonTypeShutterShort) {
            self.shutterShortPressTimes++;
        } else if (value == PDPhysicalButtonTypeShutterLong) {
            self.shutterLongPressTimes++;
        } else if (value == PDPhysicalButtonTypeUpShort) {
            self.upShortPressTimes++;
        } else if (value == PDPhysicalButtonTypeUpLong) {
            self.upLongPressTimes++;
        } else if (value == PDPhysicalButtonTypeDownShort) {
            self.downShortPressTimes++;
        } else if (value == PDPhysicalButtonTypeDownLong) {
            self.downLongPressTimes++;
        } else if (value == PDPhysicalButtonTypeLeftShort) {
            self.leftShortPressTimes++;
        } else if (value == PDPhysicalButtonTypeLeftLong) {
            self.leftLongPressTimes++;
        } else if (value == PDPhysicalButtonTypeRightShort) {
            self.rightShortPressTimes++;
        } else if (value == PDPhysicalButtonTypeRightLong) {
            self.rightLongPressTimes++;
        }
    };
    
    // !!!: 电池信息回调
    [PDBluetoothManager shareInstance].batteryCharacteristic = ^(NSInteger battery) {
        @strongify(self);
        NSLog(@"当前电量：%ld", battery);
        self.batteryLabel.text = [NSString stringWithFormat:@"%ld%%", (long)battery];
    };
    
    // !!!: 制造商回调
    [PDBluetoothManager shareInstance].manufacturerInformationCharacteristic = ^(NSString * _Nonnull manufacturer) {
        @strongify(self);
        NSLog(@"制造商：%@", manufacturer);
        self.deviceInfoModel.manufacturer = manufacturer;
    };
    // !!!: 产品型号回调
    [PDBluetoothManager shareInstance].productModelCharacteristic = ^(NSString * _Nonnull product) {
        @strongify(self);
        NSLog(@"产品型号：%@", product);
        self.deviceInfoModel.product = product;
    };
    // !!!: 硬件版本回调
    [PDBluetoothManager shareInstance].hardwareInformationCharacteristic = ^(NSString * _Nonnull hardware) {
        @strongify(self);
        NSLog(@"硬件版本：%@", hardware);
        self.deviceInfoModel.hardware = hardware;
    };
    // !!!: 软件版本回调
    [PDBluetoothManager shareInstance].softwareInformationCharacteristic = ^(NSString * _Nonnull software) {
        @strongify(self);
        NSLog(@"软件版本：%@", software);
        self.deviceInfoModel.software = software;
    };
    // !!!: 固件版本回调
    [PDBluetoothManager shareInstance].firmwareInformationCharacteristic = ^(NSString * _Nonnull firmware) {
        @strongify(self);
        NSLog(@"固件版本：%@", firmware);
        self.deviceInfoModel.firmware = firmware;
    };
    // !!!: 水压
    [PDBluetoothManager shareInstance].waterPressureCharacteristic = ^(float water) {
        NSLog(@"当前水压：%f", water);
        self.deviceInfoModel.waterPressure = water;
    };
    // !!!: 气压
    [PDBluetoothManager shareInstance].gasPressureCharacteristic = ^(int gas) {
        NSLog(@"当前气压：%d", gas);
        self.deviceInfoModel.gasPressure = gas;
    };
    // !!!: 温度
    [PDBluetoothManager shareInstance].temperatureCharacteristic = ^(float temperature) {
        NSLog(@"当前温度：%f", temperature);
        self.deviceInfoModel.temperature = temperature;
    };
    // !!!: 漏水检测
    [PDBluetoothManager shareInstance].leakCharacteristic = ^(BOOL leak) {
        self.leakResultStr = [NSString stringWithFormat:@"%d", leak];
        NSLog(@"当前是否漏水：%d", leak);
    };
    // !!!: 马达状态
    [PDBluetoothManager shareInstance].motorCharacteristic = ^(int motorStatus) {
        self.motorResultStr = [NSString stringWithFormat:@"%@%ld", self.motorResultStr, (long)motorStatus];
        NSLog(@"当前马达状态：%d", motorStatus);
    };
}

#pragma mark - 添加观察者
- (void)addObserver {
    @weakify(self);
    NSString* (^intToStringBlock)(id value) = ^(id value) {
        return [NSString stringWithFormat:@"%@", value];
    };
    // 绑定数据
    RAC(self.bleView, hidden) = [RACObserve(self.deviceInfoModel, name) map:^id _Nullable(id  _Nullable value) {
        return @(!isEmptyString(value));
    }];
    RAC(self.bleNameLabel, text) = RACObserve(self.deviceInfoModel, name);
    RAC(self.macLabel, text) = RACObserve(self.deviceInfoModel, mac);
    RAC(self.manufacturerLabel, text) = RACObserve(self.deviceInfoModel, manufacturer);
    RAC(self.productLabel, text) = RACObserve(self.deviceInfoModel, product);
    RAC(self.hardwareLabel, text) = RACObserve(self.deviceInfoModel, hardware);
    RAC(self.softwareLabel, text) = RACObserve(self.deviceInfoModel, software);
    RAC(self.firmwareLabel, text) = RACObserve(self.deviceInfoModel, firmware);
    RAC(self.waterPressureLabel, text) = [RACObserve(self.deviceInfoModel, waterPressure) map:^id _Nullable(NSNumber *value) {
        return [NSString stringWithFormat:@"%.1f", value.floatValue];
    }];
    RAC(self.temperatureLabel, text) = [RACObserve(self.deviceInfoModel, temperature) map:^id _Nullable(NSNumber *value) {
        return [NSString stringWithFormat:@"%.2f", value.floatValue];
    }];
    RAC(self.gasPressureLabel, text) = [RACObserve(self.deviceInfoModel, gasPressure) map:^id _Nullable(NSNumber * _Nullable value) {
        return [NSString stringWithFormat:@"%@", value];
    }];
    // 长按短按次数
    RAC(self.shutterShortPressTimesLabel, text) =   [RACObserve(self, shutterShortPressTimes) map:intToStringBlock];
    RAC(self.shutterLongPressTimesLabel, text) =    [RACObserve(self, shutterLongPressTimes) map:intToStringBlock];
    RAC(self.upShortPressTimesLabel, text) =        [RACObserve(self, upShortPressTimes) map:intToStringBlock];
    RAC(self.upLongPressTimesLabel, text) =         [RACObserve(self, upLongPressTimes) map:intToStringBlock];
    RAC(self.downShortPressTimesLabel, text) =      [RACObserve(self, downShortPressTimes) map:intToStringBlock];
    RAC(self.downLongPressTimesLabel, text) =       [RACObserve(self, downLongPressTimes) map:intToStringBlock];
    RAC(self.leftShortPressTimesLabel, text) =      [RACObserve(self, leftShortPressTimes) map:intToStringBlock];
    RAC(self.leftLongPressTimesLabel, text) =       [RACObserve(self, leftLongPressTimes) map:intToStringBlock];
    RAC(self.rightShortPressTimesLabel, text) =     [RACObserve(self, rightShortPressTimes) map:intToStringBlock];
    RAC(self.rightLongPressTimesLabel, text) =      [RACObserve(self, rightLongPressTimes) map:intToStringBlock];
    
    RAC(self.leakLabel, text) = [RACObserve(self, leakResultStr) map:^id _Nullable(NSString * _Nullable value) {
        if (!isEmptyString(value)) {
            return value.intValue == 1 ? @"漏水" : @"不漏水";
        }
        return @"";
    }];
    
    // RAC压缩组合监听【设备信息】
    [[[RACSignal zip:@[RACObserve(self.deviceInfoModel, name), RACObserve(self.deviceInfoModel, mac), RACObserve(self.deviceInfoModel, manufacturer), RACObserve(self.deviceInfoModel, software), RACObserve(self.deviceInfoModel, hardware), RACObserve(self.deviceInfoModel, firmware), RACObserve(self.deviceInfoModel, product)]] skip:1] subscribeNext:^(RACTuple * _Nullable x) {
        // 等设备信息结果都出了后监听测试传感器
        [[PDBluetoothManager shareInstance] notifySenseValue];
        // 漏水测试
        [[PDBluetoothManager shareInstance] startTestLeak];
    }];
    // 快门按键
    [[RACObserve(self.deviceInfoModel, shutter) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"快门结果 ResultStr ：%@", x);
        if (isEmptyString(x)) {
            return;
        }
    }];
    // 上按键
    [[RACObserve(self.deviceInfoModel, up) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
    }];
    // 下按键
    [[RACObserve(self.deviceInfoModel, down) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
    }];
    // 左按键
    [[RACObserve(self.deviceInfoModel, left) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
    }];
    // 右按键
    [[RACObserve(self.deviceInfoModel, right) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
    }];
    
    // 漏水检测
    [[RACObserve(self, leakResultStr) skip:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"漏水结果 leakResultStr ：%@", x);
    }];
    // 马达检测
    [[RACObserve(self, motorResultStr) skip:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"马达结果 motorResultStr ：%@", x);
    }];
    // 漏水检测结果
    [[RACObserve(self.deviceInfoModel, leak) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
    }];
    // 总的检测结果
    [[RACSignal combineLatest:@[RACObserve(self.deviceInfoModel, shutter), RACObserve(self.deviceInfoModel, up), RACObserve(self.deviceInfoModel, down), RACObserve(self.deviceInfoModel, left), RACObserve(self.deviceInfoModel, right), RACObserve(self.deviceInfoModel, leak)] reduce:^id _Nonnull (NSString *shutter, NSString *up, NSString *down, NSString *left, NSString *right, NSString *leak){
        if ([shutter isEqualToString:kTestResultOK] && [up isEqualToString:kTestResultOK] && [down isEqualToString:kTestResultOK] && [left isEqualToString:kTestResultOK] && [right isEqualToString:kTestResultOK] && [leak isEqualToString:kTestResultOK]) {
            return kTestResultOK;
        } else {
            return kTestResultNC;
        }
    }] subscribeNext:^(NSString * _Nullable x) {
        self.deviceInfoModel.result = x;
    }];
}

#pragma mark - 事件
/// 点击打开马达
- (IBAction)clickOpenMotor:(UIButton *)sender {
    [[PDBluetoothManager shareInstance] openMotor:YES];
}
/// 点击关闭马达
- (IBAction)clickCloseMotor:(UIButton *)sender {
    [[PDBluetoothManager shareInstance] openMotor:NO];
}
/// 点击关机
- (IBAction)clickShutdown:(UIButton *)sender {
    [[PDBluetoothManager shareInstance] shutdownDevice];
    [MBProgressHUD showMessage:@"已发送关机指令"];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralArrM.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"peripheralTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.peripheralArrM[indexPath.row] mac];
    cell.textLabel.textColor = kColorBlue1;
    return cell;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.peripheralArrM[indexPath.row].mac) {
        [[PDBluetoothManager shareInstance] stopScan];
        // 连接到指定外围
        [[PDBluetoothManager shareInstance].centralManager connectPeripheral:self.peripheralArrM[indexPath.row] options:nil];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}
@end
