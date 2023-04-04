//
//  ViewController.h
//  WeefineTestTool
//
//  Created by paddy on 2023/3/30.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.pch"

@interface ViewController : UIViewController

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


@end

