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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 马达状态：已打开、已抽气完成、已正常关闭、超时打开
    
    // 初始化数据
    [self setupData];
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
- (void)setupData {
    self.deviceInfoModel = [[DeviceInfoModel alloc] init];
    self.shortPressTimes = 0;
    self.longPressTimes = 0;
    self.stackViewArray = @[self.stackView0, self.stackView1, self.stackView2, self.stackView3, self.stackView4, self.stackView5, self.stackView6, self.stackView7, self.stackView8, self.stackView9];
    self.stepDetailViewArray = @[self.tableView, self.deviceInfoView, self.sensorView, self.keyView, self.leakView, self.turnOffView];
    self.keyTitleDic = @{@"3":@[kKeyTitle(@"快门"), kKeyShortTitle(@"快门"), kKeyLongTitle(@"快门")],
                         @"4":@[kKeyTitle(@"上"), kKeyShortTitle(@"上"), kKeyLongTitle(@"上")],
                         @"5":@[kKeyTitle(@"下"), kKeyShortTitle(@"下"), kKeyLongTitle(@"下")],
                         @"6":@[kKeyTitle(@"左"), kKeyShortTitle(@"左"), kKeyLongTitle(@"左")],
                         @"7":@[kKeyTitle(@"右"), kKeyShortTitle(@"右"), kKeyLongTitle(@"右")]};
    self.step = 0;
}

- (void)setupUI {
    
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
        self.step++;
        self.deviceInfoModel.name = name;
        self.deviceInfoModel.mac = [PDBluetoothManager shareInstance].peripheral.mac;
    };
    
    // !!!: 连接断开
    [PDBluetoothManager shareInstance].didDisconnectPeripheral = ^(NSString *name) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@：%@",LocalizedString(@"连接已断开"), name]];
        @strongify(self);
        self.deviceInfoModel = [[DeviceInfoModel alloc] init];
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
        NSLog(@"当前是否漏水：%d", leak);
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
    // 根据步骤切换UI
    [RACObserve(self, step) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        NSLog(@"当前第几步：%@", x);
        if (x.intValue >= 10) {
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
            [self.rightBoxView bringSubviewToFront:self.keyView];
            NSString *dicKey = [NSString stringWithFormat:@"%@", x];
            self.keyTitleLabel.text = [self.keyTitleDic[dicKey] objectAtIndex:0];
            self.shortTitleLabel.text = [self.keyTitleDic[dicKey] objectAtIndex:1];
            self.longTitleLabel.text = [self.keyTitleDic[dicKey] objectAtIndex:2];
        }
        // 传感器测试
        if (x.intValue == 2) {
            [[PDBluetoothManager shareInstance] readSenseValue];
        }
    }];
    
    // RAC压缩组合监听【设备信息】
    [[[RACSignal zip:@[RACObserve(self.deviceInfoModel, name), RACObserve(self.deviceInfoModel, mac), RACObserve(self.deviceInfoModel, manufacturer), RACObserve(self.deviceInfoModel, software), RACObserve(self.deviceInfoModel, hardware), RACObserve(self.deviceInfoModel, firmware), RACObserve(self.deviceInfoModel, product)]] skip:1] subscribeNext:^(RACTuple * _Nullable x) {
        [self.connectBtn setImage:kImageOK forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSuccessNextTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.step++;
        });
    }];
    // RAC压缩组合监听【传感器信息】
    [[[RACSignal zip:@[RACObserve(self.deviceInfoModel, waterPressure), RACObserve(self.deviceInfoModel, temperature), RACObserve(self.deviceInfoModel, gasPressure)]] skip:1] subscribeNext:^(RACTuple * _Nullable x) {
        [self.sensorBtn setImage:kImageOK forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSuccessNextTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.step++;
        });
    }];
    // RAC压缩组合监听【按键检测】
    [[[RACSignal combineLatest:@[RACObserve(self, shortPressTimes), RACObserve(self, longPressTimes)] reduce:^id _Nonnull (NSNumber *shortPressTimes, NSNumber *longPressTimes){
        BOOL success = shortPressTimes.intValue >= 3 && longPressTimes.intValue >= 1;
        return @(success);
    }]  skip:1] subscribeNext:^(id  _Nullable x) {
        if ([x boolValue]) {
            UIButton *button;
            if (self.step == 3) {
                button = self.shutterBtn;
                self.deviceInfoModel.shutter = kTestResultOK;
            } else if (self.step == 4) {
                button = self.topBtn;
                self.deviceInfoModel.up = kTestResultOK;
            } else if (self.step == 5) {
                button = self.bottomBtn;
                self.deviceInfoModel.down = kTestResultOK;
            } else if (self.step == 6) {
                button = self.leftBtn;
                self.deviceInfoModel.left = kTestResultOK;
            } else if (self.step == 7) {
                button = self.rightBtn;
                self.deviceInfoModel.right = kTestResultOK;
            }
            [button setImage:kImageOK forState:UIControlStateNormal];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSuccessNextTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.step++;
                self.shortPressTimes = 0;
                self.longPressTimes = 0;
            });
        }
    }];
    
}

#pragma mark - 事件
/// 下一步
- (IBAction)nextAction:(UIButton *)sender {
    NSUInteger tag = sender.tag;
    if (tag == 1001) {
        // 设备信息页面中的下一步
        self.step++;
        [self.connectBtn setImage:kImageNC forState:UIControlStateNormal];
    } else if (tag == 1002) {
        // 传感器测试下一步
        [self.sensorBtn setImage:kImageNC forState:UIControlStateNormal];
    } else if (tag == 1003) {
        // 按键测试下一步
        if (self.step == 3) {
            self.deviceInfoModel.shutter = kTestResultNC;
            [self.shutterBtn setImage:kImageNC forState:UIControlStateNormal];
        } else if (self.step == 4) {
            self.deviceInfoModel.up = kTestResultNC;
            [self.topBtn setImage:kImageNC forState:UIControlStateNormal];
        } else if (self.step == 5) {
            self.deviceInfoModel.down = kTestResultNC;
            [self.bottomBtn setImage:kImageNC forState:UIControlStateNormal];
        } else if (self.step == 6) {
            self.deviceInfoModel.left = kTestResultNC;
            [self.leftBtn setImage:kImageNC forState:UIControlStateNormal];
        } else if (self.step == 7) {
            self.deviceInfoModel.right = kTestResultNC;
            [self.rightBtn setImage:kImageNC forState:UIControlStateNormal];
        }
    } else if (tag == 1008) {
        // 漏水测试下一步
        self.deviceInfoModel.leak = kTestResultNC;
        [self.leakBtn setImage:kImageNC forState:UIControlStateNormal];
    } else if (tag == 1009) {
        // 关机，开始下一个产品测试
    }
    self.step++;
}

/// 分享文件
- (IBAction)shareFile:(UIButton *)sender {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    if (![contents containsObject:kCSVFileName]) {
        [MBProgressHUD showMessage:@"暂无可分享的文件"];
        return;
    }
    NSString *filePath = [documentsPath stringByAppendingPathComponent:kCSVFileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSArray *activityItems = @[fileURL];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
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
    [[PDBluetoothManager shareInstance] stopScan];
    // 连接到指定外围
    [[PDBluetoothManager shareInstance].centralManager connectPeripheral:self.peripheralArrM[indexPath.row] options:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}


@end
