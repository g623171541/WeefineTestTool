//
//  MBProgressHUD+GXD.h
//  Yudo
//
//  Created by paddygu on 2020/10/26.
//  Copyright © 2020 yudo. All rights reserved.
//

#import "MBProgressHUD.h"

// 统一的显示时长
#define kHudShowTime 2.0
#define kHudShowText @"加载中..."
#define kIsUserInteractionEnabled YES //提示框显示时,是否允许点击屏幕其他地方, NO:允许,YES:不允许


NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (GXD)

#pragma mark 在指定的view上显示hud
+ (void)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showWarning:(NSString *)Warning toView:(UIView *)view;
+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view;

+ (void)showActivityMessage:(NSString*)message toView:(UIView *)view;

+ (void)showProgress:(CGFloat)progress toView:(UIView *)view;
+ (void)showProgress:(CGFloat)progress status:(NSString *)status toView:(UIView *)view;


#pragma mark 在window上显示hud
+ (void)showMessage:(NSString *)message;//文字
+ (void)showSuccess:(NSString *)success;//成功 + 文字
+ (void)showError:(NSString *)error; //错误 + 文字
+ (void)showWarning:(NSString *)Warning;//警告 + 文字
+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message;//自定义图片+文字

/** 转圈 */
+ (void)show; //转圈
+ (void)showActivityMessage:(NSString*)message; //转圈+文字

/** 加载进度 */
+ (void)showProgress:(CGFloat)progress; //显示进度,默认文字为"加载中..." 进度走完, 自动隐藏
+ (void)showProgress:(CGFloat)progress status:(NSString *)status;//显示进度,自定义显示文字 进度走完, 自动隐藏

#pragma mark -π币领取tip
+ (void)showPoint:(NSString *)point;

#pragma mark -正在提交
+ (void)showSubmit;

#pragma mark -提交完成
+ (void)showSuccessSubmit;

#pragma mark -加载中
+ (void)showLoading;

@end

NS_ASSUME_NONNULL_END
