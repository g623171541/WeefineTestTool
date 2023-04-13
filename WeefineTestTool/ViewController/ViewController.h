//
//  ViewController.h
//  WeefineTestTool
//
//  Created by paddy on 2023/3/30.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

#pragma mark - 左侧检测状态按钮

@property (weak, nonatomic) IBOutlet UIStackView *stackView0;
@property (weak, nonatomic) IBOutlet UIStackView *stackView1;
@property (weak, nonatomic) IBOutlet UIStackView *stackView2;
@property (weak, nonatomic) IBOutlet UIStackView *stackView3;
@property (weak, nonatomic) IBOutlet UIStackView *stackView4;
@property (weak, nonatomic) IBOutlet UIStackView *stackView5;
@property (weak, nonatomic) IBOutlet UIStackView *stackView6;
@property (weak, nonatomic) IBOutlet UIStackView *stackView7;
@property (weak, nonatomic) IBOutlet UIStackView *stackView8;
@property (weak, nonatomic) IBOutlet UIStackView *stackView9;

/// 左侧栏
@property (weak, nonatomic) IBOutlet UIView *leftBoxView;
/// 右侧栏
@property (weak, nonatomic) IBOutlet UIView *rightBoxView;

/// 连接测试
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
/// 传感器测试
@property (weak, nonatomic) IBOutlet UIButton *sensorBtn;
/// 快门按键测试
@property (weak, nonatomic) IBOutlet UIButton *shutterBtn;
/// 上按键测试
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
/// 下按键测试
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
/// 左按键测试
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
/// 右按键测试
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
/// 漏水测试
@property (weak, nonatomic) IBOutlet UIButton *leakBtn;
/// 关机
@property (weak, nonatomic) IBOutlet UIButton *shutdownBtn;

#pragma mark - 右侧
// !!!: 蓝牙列表
/// 蓝牙设备列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// !!!: 设备信息
/// 设备信息
@property (weak, nonatomic) IBOutlet UIView *deviceInfoView;
/// 电池
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
/// 蓝牙名称
@property (weak, nonatomic) IBOutlet UILabel *bleNameLabel;
/// 制造商
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;
/// 硬件
@property (weak, nonatomic) IBOutlet UILabel *hardwareLabel;
/// 软件
@property (weak, nonatomic) IBOutlet UILabel *softwareLabel;
/// 固件
@property (weak, nonatomic) IBOutlet UILabel *firmwareLabel;

// !!!: 传感器
/// 传感器
@property (weak, nonatomic) IBOutlet UIView *sensorView;
/// 水压
@property (weak, nonatomic) IBOutlet UILabel *waterPressureLabel;
/// 水温
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
/// 气压
@property (weak, nonatomic) IBOutlet UILabel *gasPressureLabel;


// !!!: 按键
/// 按键
@property (weak, nonatomic) IBOutlet UIView *keyView;
/// 测试标题
@property (weak, nonatomic) IBOutlet UILabel *keyTitleLabel;
/// 短按按键标题
@property (weak, nonatomic) IBOutlet UILabel *shortTitleLabel;
/// 长按按键标题
@property (weak, nonatomic) IBOutlet UILabel *longTitleLabel;
/// 短按次数
@property (weak, nonatomic) IBOutlet UILabel *shortStepLabel;
/// 长按次数
@property (weak, nonatomic) IBOutlet UILabel *longStepLabel;


// !!!: 漏水测试
/// 漏水测试
@property (weak, nonatomic) IBOutlet UIView *leakView;
/// 马达测试
@property (weak, nonatomic) IBOutlet UILabel *motorTestLabel;
/// 漏水检测
@property (weak, nonatomic) IBOutlet UILabel *leakLabel;
/// 马达状态
@property (weak, nonatomic) IBOutlet UILabel *motorStateLabel;

// !!!: 关机
/// 关机
@property (weak, nonatomic) IBOutlet UIView *turnOffView;
/// 关机右侧Label
@property (weak, nonatomic) IBOutlet UILabel *turnOffLabel;

@end

