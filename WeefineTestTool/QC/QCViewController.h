//
//  QCViewController.h
//  WeefineQC
//
//  Created by paddy on 2023/6/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QCViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

/// 蓝牙列表父View
@property (weak, nonatomic) IBOutlet UIView *bleView;
/// 蓝牙设备列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// !!!: 设备信息
/// 设备信息
@property (weak, nonatomic) IBOutlet UIView *deviceInfoView;
/// 电池
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
/// 蓝牙名称
@property (weak, nonatomic) IBOutlet UILabel *bleNameLabel;
/// MAC
@property (weak, nonatomic) IBOutlet UILabel *macLabel;
/// 制造商
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;
/// 产品型号
@property (weak, nonatomic) IBOutlet UILabel *productLabel;
/// 硬件
@property (weak, nonatomic) IBOutlet UILabel *hardwareLabel;
/// 软件
@property (weak, nonatomic) IBOutlet UILabel *softwareLabel;
/// 固件
@property (weak, nonatomic) IBOutlet UILabel *firmwareLabel;

/// 水压
@property (weak, nonatomic) IBOutlet UILabel *waterPressureLabel;
/// 水温
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
/// 气压
@property (weak, nonatomic) IBOutlet UILabel *gasPressureLabel;


// !!!: 按键
/// 短按按键标题
@property (weak, nonatomic) IBOutlet UILabel *shortTitleLabel;
/// 长按按键标题
@property (weak, nonatomic) IBOutlet UILabel *longTitleLabel;

/// 短按【快门】按键次数
@property (weak, nonatomic) IBOutlet UILabel *shutterShortPressTimesLabel;
/// 长按【快门】按键次数
@property (weak, nonatomic) IBOutlet UILabel *shutterLongPressTimesLabel;
/// 短按【上】按键次数
@property (weak, nonatomic) IBOutlet UILabel *upShortPressTimesLabel;
/// 长按【上】按键次数
@property (weak, nonatomic) IBOutlet UILabel *upLongPressTimesLabel;
/// 短按【下】按键次数
@property (weak, nonatomic) IBOutlet UILabel *downShortPressTimesLabel;
/// 长按【下】按键次数
@property (weak, nonatomic) IBOutlet UILabel *downLongPressTimesLabel;
/// 短按【左】按键次数
@property (weak, nonatomic) IBOutlet UILabel *leftShortPressTimesLabel;
/// 长按【左】按键次数
@property (weak, nonatomic) IBOutlet UILabel *leftLongPressTimesLabel;
/// 短按【右】按键次数
@property (weak, nonatomic) IBOutlet UILabel *rightShortPressTimesLabel;
/// 长按【右】按键次数
@property (weak, nonatomic) IBOutlet UILabel *rightLongPressTimesLabel;


/// 漏水检测
@property (weak, nonatomic) IBOutlet UILabel *leakLabel;
/// 关机右侧按钮
@property (weak, nonatomic) IBOutlet UIButton *shutdownButton;

@end

NS_ASSUME_NONNULL_END
