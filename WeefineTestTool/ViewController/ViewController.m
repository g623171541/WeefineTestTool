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
@property (nonatomic, strong) NSMutableDictionary *dicM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 马达状态：已打开、已抽气完成、已正常关闭、超时打开
    
    // 初始化数据
    [self initData];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dicM setValue:@"123" forKey:@"soft"];
    });
}

/// 初始化数据
- (void)initData {
    self.deviceInfoModel = [[DeviceInfoModel alloc] init];
    self.dicM = [NSMutableDictionary dictionary];
    self.stackViewArray = @[self.stackView0, self.stackView1, self.stackView2, self.stackView3, self.stackView4, self.stackView5, self.stackView6, self.stackView7, self.stackView8, self.stackView9];
    self.stepDetailViewArray = @[self.tableView, self.deviceInfoView, self.sensorView, self.keyView, self.leakView, self.turnOffView];
    self.keyTitleDic = @{@"3":@[kKeyTitle(@"快门"), kKeyShortTitle(@"快门"), kKeyLongTitle(@"快门")],
                         @"4":@[kKeyTitle(@"上"), kKeyShortTitle(@"上"), kKeyLongTitle(@"上")],
                         @"5":@[kKeyTitle(@"下"), kKeyShortTitle(@"下"), kKeyLongTitle(@"下")],
                         @"6":@[kKeyTitle(@"左"), kKeyShortTitle(@"左"), kKeyLongTitle(@"左")],
                         @"7":@[kKeyTitle(@"右"), kKeyShortTitle(@"右"), kKeyLongTitle(@"右")]};
    self.step = 0;
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
    };
    
    // !!!: 按键信息回调
    [PDBluetoothManager shareInstance].buttonCharacteristic = ^(NSString *buttonString) {
        NSLog(@"按下了按键-【按键编号:%@】",buttonString);
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
    };
    // !!!: 气压
    [PDBluetoothManager shareInstance].gasPressureCharacteristic = ^(float gas) {
        NSLog(@"当前气压：%f", gas);
    };
    // !!!: 温度
    [PDBluetoothManager shareInstance].temperatureCharacteristic = ^(float temperature) {
        NSLog(@"当前温度：%f", temperature);
    };
    // !!!: 漏水检测
    [PDBluetoothManager shareInstance].leakCharacteristic = ^(BOOL leak) {
        NSLog(@"当前是否漏水：%d", leak);
    };
    
}

#pragma mark - 按键事件处理
/// 点击拍照事件
- (void)click0TakePhotoEvent {
    NSLog(@"【点击】点击拍照事件");
}

/// 点击对焦事件
- (void)click1DiveMFOrAFEvent {
    NSLog(@"【点击】点击对焦事件");
}

/// 点击模式/返回事件
- (void)click2ModeBackEvent {
    NSLog(@"【点击】点击模式");
}

/// 点击上一个/深度事件
- (void)click3UpDepthEvent {
    NSLog(@"【点击】点击上一个");
}

/// 点击菜单/OK事件
- (void)click4MenuOkEvent:(BOOL)isTouchScreen {
    NSLog(@"【点击】点击菜单/OK事件");
}

/// 点击下一个/滤镜事件
- (void)click5DownFilterEvent {
    NSLog(@"【点击】点击下一个");
}

/// 长按对焦事件
- (void)click6DiveMFOrAFLongEvent {
    NSLog(@"【点击】长按对焦事件");
}

#pragma mark - 添加观察者
- (void)addObserver {
    @weakify(self);
    // 绑定数据
    RAC(self.bleNameLabel, text) = RACObserve(self.deviceInfoModel, name);
    RAC(self.macLabel, text) = RACObserve(self.deviceInfoModel, mac);
    RAC(self.manufacturerLabel, text) = RACObserve(self.deviceInfoModel, manufacturer);
    RAC(self.hardwareLabel, text) = RACObserve(self.deviceInfoModel, hardware);
    RAC(self.softwareLabel, text) = RACObserve(self.deviceInfoModel, software);
    RAC(self.firmwareLabel, text) = RACObserve(self.deviceInfoModel, firmware);
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
    }];
    
    [RACObserve(self, dicM) subscribeNext:^(id  _Nullable x) {
        NSLog(@"监听到改变：%@", x);
    }];
}

#pragma mark - 事件
/// 下一步
- (IBAction)nextAction:(UIButton *)sender {
    NSUInteger tag = sender.tag;
    if (tag == 1001) {
        // 设备信息页面中的下一步
        self.step++;
    } else if (tag == 1002) {
        // 传感器测试下一步
    } else if (tag == 1003) {
        // 按键测试下一步
    } else if (tag == 1008) {
        // 漏水测试下一步
    } else if (tag == 1009) {
        // 关机，开始下一个产品测试
    }
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
