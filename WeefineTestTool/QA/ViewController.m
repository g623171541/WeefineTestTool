//
//  ViewController.m
//  WeefineTestTool
//
//  Created by paddy on 2023/3/30.
//

#import "ViewController.h"

#define kKeyTitle(key)          [NSString stringWithFormat:@"%@按键测试", key]
#define kKeyShortTitle(key)     [NSString stringWithFormat:@"短按三下%@按键", key]
#define kKeyLongTitle(key)      [NSString stringWithFormat:@"长按一下%@按键", key]
#define kSuccessNextTime        3.0
#define kImageOK                [UIImage imageNamed:@"icon_ok"]
#define kImageNC                [UIImage imageNamed:@"icon_error"]

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

@interface ViewController ()
/// 当前第几步骤
@property (nonatomic, assign) NSInteger step;
/// 步骤view数组，用于改变背景颜色
@property (nonatomic, strong) NSArray *stackViewArray;
/// 右侧检测结果view数组，用于显示当前哪一步
@property (nonatomic, strong) NSArray *stepDetailViewArray;
/// 5个按键标题修改
@property (nonatomic, strong) NSDictionary <NSString *, NSArray <NSString *>*>*keyTitleDic;
/// 设备测试模型
@property (nonatomic, strong) DeviceInfoModel *deviceInfoModel;
/// 蓝牙外设设备列表
@property (nonatomic, strong) NSMutableArray <CBPeripheral *>*peripheralArrM;
/// 短按按键次数
@property (nonatomic, assign) NSInteger shortPressTimes;
/// 长按按键次数
@property (nonatomic, assign) NSInteger longPressTimes;
/// 漏水测试结果，保存格式为010，0代表不漏水，1代表漏水
@property (nonatomic, strong) NSString *leakResultStr;
/// 马达测试结果
@property (nonatomic, strong) NSString *motorResultStr;
/// 已经发送关机指令
@property (nonatomic, assign) BOOL alreadySendShutdown;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化数据
    [self initData];
    [self setupData];
    // 初始化UI
    [self setupUI];
    // 添加观察者
    [self addObserver];
    // 加载蓝牙模块
    [self loadBluetoothManager];
    
//    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        self.step ++;
//        if (self.step >= 10) {
//            self.step = 0;
//        }
//    }];
}

/// 初始化数据
- (void)initData {
    // 创建表
    [[DataBaseManager sharedFMDataBase] createTable:kTableName];
    self.stackViewArray = @[self.stackView0, self.stackView1, self.stackView2, self.stackView3, self.stackView4, self.stackView5, self.stackView6, self.stackView7, self.stackView8, self.stackView9];
    self.stepDetailViewArray = @[self.tableView, self.deviceInfoView, self.sensorView, self.keyView, self.leakView, self.turnOffView];
    self.keyTitleDic = @{@"3":@[kKeyTitle(@"快门"), kKeyShortTitle(@"快门"), kKeyLongTitle(@"快门")],
                         @"4":@[kKeyTitle(@"上"), kKeyShortTitle(@"上"), kKeyLongTitle(@"上")],
                         @"5":@[kKeyTitle(@"下"), kKeyShortTitle(@"下"), kKeyLongTitle(@"下")],
                         @"6":@[kKeyTitle(@"左"), kKeyShortTitle(@"左"), kKeyLongTitle(@"左")],
                         @"7":@[kKeyTitle(@"右"), kKeyShortTitle(@"右"), kKeyLongTitle(@"右")]};
    self.deviceInfoModel = [[DeviceInfoModel alloc] init];
}

- (void)setupData {
    [self.deviceInfoModel reset];
    self.leakResultStr = @"";
    self.motorResultStr = @"";
    self.shortPressTimes = 0;
    self.longPressTimes = 0;
    self.alreadySendShutdown = NO;
    self.step = 0;
}

- (void)setupUI {
    [self.motorTestBtn setTitle:@"打开马达" forState:UIControlStateNormal];
    [self.motorTestBtn setTitle:@"关闭马达" forState:UIControlStateSelected];
    [self.shutdownButton setTitle:@"关机" forState:UIControlStateNormal];
    [self.shutdownButton setTitle:@"已关机" forState:UIControlStateSelected];
    [self.connectBtn setImage:nil forState:UIControlStateNormal];
    [self.sensorBtn setImage:nil forState:UIControlStateNormal];
    [self.shutterBtn setImage:nil forState:UIControlStateNormal];
    [self.topBtn setImage:nil forState:UIControlStateNormal];
    [self.bottomBtn setImage:nil forState:UIControlStateNormal];
    [self.leftBtn setImage:nil forState:UIControlStateNormal];
    [self.rightBtn setImage:nil forState:UIControlStateNormal];
    [self.leakBtn setImage:nil forState:UIControlStateNormal];
    [self.shutdownBtn setImage:nil forState:UIControlStateNormal];
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
        // tableView移除连接的设备
        if ([self.peripheralArrM containsObject:[PDBluetoothManager shareInstance].peripheral]) {
            [self.peripheralArrM removeObject:[PDBluetoothManager shareInstance].peripheral];
            [self.tableView reloadData];
        }
        self.step++;
        self.deviceInfoModel.name = name;
        self.deviceInfoModel.mac = [PDBluetoothManager shareInstance].peripheral.mac;
    };
    
    // !!!: 连接断开
    [PDBluetoothManager shareInstance].didDisconnectPeripheral = ^(NSString *name) {
        @strongify(self);
        if (self.alreadySendShutdown) {
            self.shutdownButton.selected = YES;
            self.deviceInfoModel.shutdown = kTestResultOK;
            [self.shutdownBtn setImage:kImageOK forState:UIControlStateNormal];
            [MBProgressHUD showMessage:[NSString stringWithFormat:@"%@已完成测试", self.deviceInfoModel.mac]];
            // 写入数据
            [[DataBaseManager sharedFMDataBase] insertModel:self.deviceInfoModel tableName:kTableName];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@：%@",LocalizedString(@"连接已断开"), name]];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupData];
            [self setupUI];
            [PDBluetoothManager deleteInstance];
            [self loadBluetoothManager];
        });
    };
    
    // !!!: 按键信息回调
    [PDBluetoothManager shareInstance].buttonCharacteristic = ^(int value) {
        NSLog(@"按下了按键-【按键编号:%x】", value);
        @strongify(self);
        if (value == PDPhysicalButtonTypeShutterShort && self.step == 3) {
            self.shortPressTimes++;
        } else if (value == PDPhysicalButtonTypeShutterLong && self.step == 3) {
            self.longPressTimes++;
        } else if (value == PDPhysicalButtonTypeUpShort && self.step == 4) {
            self.shortPressTimes++;
        } else if (value == PDPhysicalButtonTypeUpLong && self.step == 4) {
            self.longPressTimes++;
        } else if (value == PDPhysicalButtonTypeDownShort && self.step == 5) {
            self.shortPressTimes++;
        } else if (value == PDPhysicalButtonTypeDownLong && self.step == 5) {
            self.longPressTimes++;
        } else if (value == PDPhysicalButtonTypeLeftShort && self.step == 6) {
            self.shortPressTimes++;
        } else if (value == PDPhysicalButtonTypeLeftLong && self.step == 6) {
            self.longPressTimes++;
        } else if (value == PDPhysicalButtonTypeRightShort && self.step == 7) {
            self.shortPressTimes++;
        } else if (value == PDPhysicalButtonTypeRightLong && self.step == 7) {
            self.longPressTimes++;
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
        self.leakResultStr = [NSString stringWithFormat:@"%@%d", self.leakResultStr, leak];
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
    // 绑定数据
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
    RAC(self.gasPressureLabel, text) = [RACObserve(self.deviceInfoModel, gasPressure) map:^id _Nullable(NSNumber *value) {
        return [NSString stringWithFormat:@"%@", value];
    }];
    RAC(self.shortTimesLabel, text) = [RACObserve(self, shortPressTimes) map:^id _Nullable(NSNumber *value) {
        return [NSString stringWithFormat:@"%@", value];
    }];
    RAC(self.longTimesLabel, text) = [RACObserve(self, longPressTimes) map:^id _Nullable(NSNumber *value) {
        return [NSString stringWithFormat:@"%@", value];
    }];
    RAC(self.leakLabel, text) = [RACObserve(self, leakResultStr) map:^id _Nullable(NSString * _Nullable value) {
        if (!isEmptyString(value)) {
            return [[value substringFromIndex:value.length-1] intValue] == 1 ? @"漏水" : @"不漏水";
        }
        return @"";
    }];
    RAC(self.motorStateLabel, text) = [RACObserve(self, motorResultStr) map:^id _Nullable(NSString * _Nullable value) {
        if (value.length) {
            int statue = [[value substringFromIndex:value.length-1] intValue];
            if (statue == 1) {
                return @"APP指令打开";
            } else if (statue == 2) {
                return @"APP指令关闭";
            } else if (statue == 2) {
                return @"抽气完成关闭";
            } else if (statue == 4) {
                return @"超时打开";
            }
        }
        return @"初始状态";
    }];
    // 根据步骤切换UI
    [RACObserve(self, step) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        NSLog(@"当前第几步：%@", x);
        if (x.intValue >= 10) {
            self.step = 0;
            return;
        }
        for (int i=0; i<self.stackViewArray.count; i++) {
            UIStackView *stackView = [self.stackViewArray objectAtIndex:i];
            stackView.backgroundColor = [x intValue] == i ? kColorGrey3 : UIColor.whiteColor;
        }
        
        if (x.intValue <= 2) {
            [self.rightBoxView bringSubviewToFront:self.stepDetailViewArray[x.intValue]];
        } else if (x.intValue == 8 || x.intValue == 9) {
            [self.rightBoxView bringSubviewToFront:self.stepDetailViewArray[x.intValue-4]];
        } else {
            // 按键视图
            [self.rightBoxView bringSubviewToFront:self.keyView];
            NSString *dicKey = [NSString stringWithFormat:@"%@", x];
            self.keyTitleLabel.text = [self.keyTitleDic[dicKey] objectAtIndex:0];
            self.shortTitleLabel.text = [self.keyTitleDic[dicKey] objectAtIndex:1];
            self.longTitleLabel.text = [self.keyTitleDic[dicKey] objectAtIndex:2];
        }
        
        if (x.intValue == 2) {
            // 传感器测试
            [[PDBluetoothManager shareInstance] readSenseValue];
        } else if (x.intValue == 8) {
            // 漏水测试
            [[PDBluetoothManager shareInstance] startTestLeak];
        } else if (x.intValue == 9) {
            // 关机测试
            [[PDBluetoothManager shareInstance] shutdownDevice];
            self.alreadySendShutdown = YES;
        }
    }];
    
    // RAC压缩组合监听【设备信息】
    [[[RACSignal zip:@[RACObserve(self.deviceInfoModel, name), RACObserve(self.deviceInfoModel, mac), RACObserve(self.deviceInfoModel, manufacturer), RACObserve(self.deviceInfoModel, software), RACObserve(self.deviceInfoModel, hardware), RACObserve(self.deviceInfoModel, firmware), RACObserve(self.deviceInfoModel, product)]] skip:1] subscribeNext:^(RACTuple * _Nullable x) {
        int emptyCount = 0;
        NSString *result = kTestResultOK;
        for (NSString *s in x) {
            if (isEmptyString(s)) {
                result = kTestResultNC;
                emptyCount += 1;
            }
        }
        self.deviceInfoModel.deviceInfoResult = emptyCount==7 ? @"" : result;
    }];
    [[RACObserve(self.deviceInfoModel, deviceInfoResult) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.connectBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.connectBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStep) withObject:nil afterDelay:kSuccessNextTime];
    }];
    // RAC压缩组合监听【传感器信息】
    [[[RACSignal zip:@[RACObserve(self.deviceInfoModel, waterPressure), RACObserve(self.deviceInfoModel, temperature), RACObserve(self.deviceInfoModel, gasPressure)]] skip:1] subscribeNext:^(RACTuple * _Nullable x) {
        NSString *result = kTestResultOK;
        for (NSNumber *number in x) {
            if (number == 0) {
                result = kTestResultNC;
                break;
            }
        }
        self.deviceInfoModel.senseInfoResult = result;
    }];
    [[RACObserve(self.deviceInfoModel, senseInfoResult) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.sensorBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.sensorBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStep) withObject:nil afterDelay:kSuccessNextTime];
    }];
    // RAC压缩组合监听【按键检测】
    [[[RACSignal combineLatest:@[RACObserve(self, shortPressTimes), RACObserve(self, longPressTimes)] reduce:^id _Nonnull (NSNumber *shortPressTimes, NSNumber *longPressTimes){
        BOOL success = shortPressTimes.intValue >= 3 && longPressTimes.intValue >= 1;
        return @(success);
    }]  skip:1] subscribeNext:^(id  _Nullable x) {
        if ([x boolValue]) {
            if (self.step == 3) {
                self.deviceInfoModel.shutter = kTestResultOK;
            } else if (self.step == 4) {
                self.deviceInfoModel.up = kTestResultOK;
            } else if (self.step == 5) {
                self.deviceInfoModel.down = kTestResultOK;
            } else if (self.step == 6) {
                self.deviceInfoModel.left = kTestResultOK;
            } else if (self.step == 7) {
                self.deviceInfoModel.right = kTestResultOK;
            }
        }
    }];
    // 快门按键
    [[RACObserve(self.deviceInfoModel, shutter) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"快门结果 ResultStr ：%@", x);
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.shutterBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.shutterBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStepOfKey) withObject:nil afterDelay:kSuccessNextTime];
    }];
    // 上按键
    [[RACObserve(self.deviceInfoModel, up) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.topBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.topBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStepOfKey) withObject:nil afterDelay:kSuccessNextTime];
    }];
    // 下按键
    [[RACObserve(self.deviceInfoModel, down) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.bottomBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.bottomBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStepOfKey) withObject:nil afterDelay:kSuccessNextTime];
    }];
    // 左按键
    [[RACObserve(self.deviceInfoModel, left) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.leftBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.leftBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStepOfKey) withObject:nil afterDelay:kSuccessNextTime];
    }];
    // 右按键
    [[RACObserve(self.deviceInfoModel, right) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.rightBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.rightBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStepOfKey) withObject:nil afterDelay:kSuccessNextTime];
    }];
    
    // 漏水检测
    [[RACObserve(self, leakResultStr) skip:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"漏水结果 leakResultStr ：%@", x);
    }];
    // 马达检测
    [[RACObserve(self, motorResultStr) skip:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"马达结果 motorResultStr ：%@", x);
    }];
    // 判断漏水检测这一步骤是否通过，包括漏水&马达
    [[[RACSignal combineLatest:@[RACObserve(self, motorResultStr), RACObserve(self, leakResultStr)] reduce:^id _Nonnull (NSString *motorResultStr, NSString *leakResultStr){
        BOOL success = [motorResultStr containsString:@"012"] && [leakResultStr containsString:@"010"];
        return @(success);
    }]  skip:1] subscribeNext:^(id  _Nullable x) {
        if ([x boolValue]) {
            self.deviceInfoModel.leak = kTestResultOK;
        }
    }];
    // 漏水检测结果
    [[RACObserve(self.deviceInfoModel, leak) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if (isEmptyString(x)) {
            return;
        }
        if ([x isEqualToString:kTestResultOK]) {
            [self.leakBtn setImage:kImageOK forState:UIControlStateNormal];
        } else if ([x isEqualToString:kTestResultNC]) {
            [self.leakBtn setImage:kImageNC forState:UIControlStateNormal];
        }
        [self performSelector:@selector(nextStepOfLeak) withObject:nil afterDelay:kSuccessNextTime];
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
    [[RACObserve(self, alreadySendShutdown) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        if ([x boolValue]) {
            [MBProgressHUD showMessage:@"已发送关机指令"];
        }
    }];
}

/// 下一步，用于延时执行
- (void)nextStep {
    self.step += 1;
}
/// 下一步，用于延时执行【按键检测】
- (void)nextStepOfKey {
    self.step += 1;
    self.shortPressTimes = 0;
    self.longPressTimes = 0;
}
/// 下一步，用于延时执行【漏水检测】
- (void)nextStepOfLeak {
    self.step++;
    self.motorResultStr = @"";
    self.leakResultStr = @"";
}

#pragma mark - 事件
/// 下一步
- (IBAction)nextAction:(UIButton *)sender {
    NSUInteger tag = sender.tag;
    if (tag == 1001) {
        // 设备信息页面中的下一步
        self.deviceInfoModel.deviceInfoResult = [self.deviceInfoModel.deviceInfoResult isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStep) object:nil];
        self.step++;
    } else if (tag == 1002) {
        // 传感器测试下一步
        self.deviceInfoModel.senseInfoResult = [self.deviceInfoModel.senseInfoResult isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStep) object:nil];
        self.step++;
    } else if (tag == 1003) {
        // 按键测试下一步
        if (self.step == 3) {
            self.deviceInfoModel.shutter = [self.deviceInfoModel.shutter isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStepOfKey) object:nil];
            [self nextStepOfKey];
        } else if (self.step == 4) {
            self.deviceInfoModel.up = [self.deviceInfoModel.up isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStepOfKey) object:nil];
            [self nextStepOfKey];
        } else if (self.step == 5) {
            self.deviceInfoModel.down = [self.deviceInfoModel.down isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStepOfKey) object:nil];
            [self nextStepOfKey];
        } else if (self.step == 6) {
            self.deviceInfoModel.left = [self.deviceInfoModel.left isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStepOfKey) object:nil];
            [self nextStepOfKey];
        } else if (self.step == 7) {
            self.deviceInfoModel.right = [self.deviceInfoModel.right isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStepOfKey) object:nil];
            [self nextStepOfKey];
        }
    } else if (tag == 1008) {
        // 漏水测试下一步
        self.deviceInfoModel.leak = [self.deviceInfoModel.leak isEqualToString:kTestResultOK] ? kTestResultOK : kTestResultNC;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextStepOfLeak) object:nil];
        [self nextStepOfLeak];
    } else if (tag == 1009) {
        // 关机，开始下一个产品测试
        [self setupData];
        self.deviceInfoModel.shutdown = kTestResultNC;
        [self.shutdownBtn setImage:kImageNC forState:UIControlStateNormal];
    }
}

/// 分享文件
- (IBAction)shareFile:(UIButton *)sender {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    if (![contents containsObject:kSQLFileName]) {
        [MBProgressHUD showMessage:@"暂无可分享的文件"];
        return;
    }
    // 导出数据
    NSString *filePath = [[DataBaseManager sharedFMDataBase] exportExcelFileWithTableName:kTableName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSArray *activityItems = @[fileURL];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    [self presentViewController:activityVC animated:YES completion:nil];
}

/// 点击马达
- (IBAction)clickMotor:(UIButton *)sender {
    [[PDBluetoothManager shareInstance] openMotor:!sender.selected];
    sender.selected = !sender.selected;
}
/// 点击关机
- (IBAction)clickShutdown:(UIButton *)sender {
    [[PDBluetoothManager shareInstance] shutdownDevice];
    self.alreadySendShutdown = YES;
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
