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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.step = 1;
    
    // 加载蓝牙模块
    [self loadBluetoothManager];
    // 添加观察者
    [self addObserver];
}



#pragma mark - 载入蓝牙管理模块
- (void)loadBluetoothManager {
    // !!!: 中央管理状态改变
    [PDBluetoothManager shareInstance].centralManagerUpdateState = ^(NSString *message) {
        [MBProgressHUD showMessage:message];
    };
    
    // !!!: 搜索到新外围回调
    [PDBluetoothManager shareInstance].discoverPeripheral = ^(NSArray *peripheralArr) {
        
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
    // 根据步骤切换UI
    [RACObserve(self, step) subscribeNext:^(id  _Nullable x) {
        NSLog(@"当前第几步：%@", x);
    }];
}


@end
