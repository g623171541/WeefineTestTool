//
//  ViewController.m
//  WeefineTestTool
//
//  Created by paddy on 2023/3/30.
//

#import "ViewController.h"

typedef NS_ENUM(NSUInteger, PDPhysicalButtonType) {
    PDPhysicalButtonTypeTakePhoto   =   20,     // 拍照/开始录像
    PDPhysicalButtonTypeModeBack    =   10,     // 模式/返回
    PDPhysicalButtonTypeUpDepth     =   40,     // 向上
    PDPhysicalButtonTypeMenuOk      =   30,     // 菜单/OK
    PDPhysicalButtonTypeDownFilter  =   50,     // 向下
    PDPhysicalButtonTypeLongFocus   =   60,     // 长按对焦
    PDPhysicalButtonTypeDive        =   61,     // 自动对焦/手动对焦
};

@interface ViewController ()
/// 当前第几步骤
@property (nonatomic, assign) NSInteger step;
/// 步骤view数组，用于改变背景颜色
@property (nonatomic, strong) NSArray *stackViewArray;
/// 设备测试模型
@property (nonatomic, strong) DeviceInfoModel *deviceInfoModel;
/// 蓝牙外设设备列表
@property (nonatomic, strong) NSMutableArray <CBPeripheral *>*peripheralArrM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数据
    [self initData];
    // 加载蓝牙模块
    [self loadBluetoothManager];
    // 添加观察者
    [self addObserver];
}

/// 初始化数据
- (void)initData {
    self.step = 0;
    self.stackViewArray = @[self.stackView0, self.stackView1, self.stackView2, self.stackView3, self.stackView4, self.stackView5, self.stackView6, self.stackView7, self.stackView8, self.stackView9];
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
        
    };
    
    // !!!: 连接断开
    [PDBluetoothManager shareInstance].didDisconnectPeripheral = ^(NSString *name) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@：%@",LocalizedString(@"连接已断开"), name]];
    };
    
    // !!!: 按键信息回调
    [PDBluetoothManager shareInstance].buttonCharacteristic = ^(NSString *buttonString) {
        NSLog(@"按下了按键-【按键编号:%@】",buttonString);
    };
    
    // !!!: 传感器信息回调
    [PDBluetoothManager shareInstance].sensorCharacteristic = ^(float temperature, float depthOfWater) {
        NSLog(@"当前温度：%f，深度：%f", temperature, depthOfWater);
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
    // 根据步骤切换UI
    [RACObserve(self, step) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        NSLog(@"当前第几步：%@", x);
        for (int i=0; i<self.stackViewArray.count; i++) {
            UIStackView *stackView = [self.stackViewArray objectAtIndex:i];
            stackView.backgroundColor = [x intValue] == i ? kColorBlue1 : UIColor.whiteColor;
        }
    }];
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
    cell.textLabel.textColor = UIColor.systemBlueColor;
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
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}


@end
