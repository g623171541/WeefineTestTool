//
//  MBProgressHUD+GXD.m
//  Yudo
//
//  Created by paddygu on 2020/10/26.
//  Copyright © 2020 yudo. All rights reserved.
//

#import "MBProgressHUD+GXD.h"

@implementation MBProgressHUD (GXD)

#pragma mark - 显示一条信息
+ (void)showMessage:(NSString *)message toView:(UIView *)view{
    [self show:message icon:nil view:view];
}

#pragma mark - 显示带图片或者不带图片的信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view{
    __block UIView *uiView = view;
    if (text == nil || text.length == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (view == nil) uiView = [[[UIApplication sharedApplication] delegate] window];
        // 快速显示一个提示信息
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:uiView animated:YES];
        hud.userInteractionEnabled = kIsUserInteractionEnabled;
        hud.label.text = text;
        hud.label.numberOfLines = 0;
        // 判断是否显示图片
        if (icon == nil) {
            hud.mode = MBProgressHUDModeText;
        }else{
            // 设置图片
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]];
            img = img == nil ? [UIImage imageNamed:icon] : img;
            hud.customView = [[UIImageView alloc] initWithImage:img];
            // 再设置模式
            hud.mode = MBProgressHUDModeCustomView;
        }
        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = YES;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.bezelView.layer.cornerRadius = 10.0f;
        hud.label.textColor = [UIColor whiteColor];
        // 指定时间之后再消失
        [hud hideAnimated:YES afterDelay:kHudShowTime];
    });
}

#pragma mark - 显示成功信息
+ (void)showSuccess:(NSString *)success toView:(UIView *)view{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark - 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

#pragma mark - 显示警告信息
+ (void)showWarning:(NSString *)Warning toView:(UIView *)view{
    [self show:Warning icon:@"warn" view:view];
}

#pragma mark - 显示自定义图片信息
+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view{
    [self show:message icon:imageName view:view];
}

#pragma mark - 加载中
+ (void)showActivityMessage:(NSString *)message toView:(UIView *)view{
    if (view == nil) view = [[[UIApplication sharedApplication] delegate] window];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = kIsUserInteractionEnabled;
    hud.label.text = message;
    // 细节文字(加载中...的下面显示)
//    hud.detailsLabelText = @"请耐心等待";
    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
}


#pragma mark - 加载中 显示进度
+ (void)showProgress:(CGFloat)progress toView:(UIView *)view{
    [MBProgressHUD showProgress:progress status:nil toView:view];
}
+ (void)showProgress:(CGFloat)progress status:(NSString *)status toView:(UIView *)view{
    
    static BOOL flag = NO;
    
    view = view == nil? [[[UIApplication sharedApplication] delegate] window] : view;
    if (flag == NO) {
        flag = YES;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.userInteractionEnabled = kIsUserInteractionEnabled;
        // 再设置模式
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = YES;
        hud.label.text = status == nil ? kHudShowText : status;
    }
    
    [MBProgressHUD HUDForView:view].progress = progress;
    if (progress >= 1.0f) {
        flag = NO;
        [[MBProgressHUD HUDForView:view] hideAnimated:YES];
    }
}


#pragma mark - 在window上显示
+ (void)show{
    [MBProgressHUD showActivityMessage:nil];
}

+ (void)showMessage:(NSString *)message{
    [self showMessage:message toView:nil];
}

+ (void)showSuccess:(NSString *)success{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error{
    [self showError:error toView:nil];
}

+ (void)showWarning:(NSString *)Warning{
    [self showWarning:Warning toView:nil];
}

+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message{
    [self showMessageWithImageName:imageName message:message toView:nil];
}

/// 加载中
+ (void)showActivityMessage:(NSString *)message{
    [MBProgressHUD showActivityMessage:message toView:nil];
}

/// 显示进度
+ (void)showProgress:(CGFloat)progress{
    [MBProgressHUD showProgress:progress status:nil];
}
//显示进度,自定义显示文字
+ (void)showProgress:(CGFloat)progress status:(NSString *)status{
    [MBProgressHUD showProgress:progress status:status toView:nil];
}

#pragma mark -π币领取tip
+ (void)showPoint:(NSString *)point {
    [self showSubmitMessage:[NSString stringWithFormat:@"π币+%@",point] icon:@"point_icon" hidAfterDelay:1.0 toView:nil];
}

#pragma mark -正在提交
+ (void)showSubmit {
    [self showSubmitMessage:@"正在提交" icon:@"show_loading" hidAfterDelay:0 toView:nil];
}

#pragma mark -提交完成
+ (void)showSuccessSubmit {
    [self showSubmitMessage:@"提交完成" icon:@"π_ic_selectSubmit" hidAfterDelay:kHudShowTime toView:nil];
}

#pragma mark - 加载中
+ (void)showLoading {
    [self showSubmitMessage:@"加载中" icon:@"show_loading" hidAfterDelay:0 toView:nil];
}

#pragma mark -图标+文字 提示框格式: afterDelay等待关闭时间，0不关闭
+ (void)showSubmitMessage:(NSString *)message icon:(NSString *)icon hidAfterDelay:(NSInteger)afterDelay toView:(UIView *)view {
    if (view == nil) view = [[[UIApplication sharedApplication] delegate] window];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.bezelView.color = [UIColor clearColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.blurEffectStyle = UIBlurEffectStyleExtraLight;
    
    hud.backgroundView.color = [UIColor clearColor];
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.blurEffectStyle = UIBlurEffectStyleExtraLight;
    
    UIView *bgView = [[UIView alloc]init];
    bgView.clipsToBounds = YES;
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_qian"]];
    bgImgView.contentMode = UIViewContentModeScaleAspectFit;
    [bgView addSubview:bgImgView];
    
    UIImageView *iconImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:icon]];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    [bgView addSubview:iconImgView];
    
    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.text = message;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:messageLabel];
    
    hud.customView = bgView;
    hud.customView.backgroundColor = [UIColor clearColor];
    hud.customView.clipsToBounds = YES;
    hud.customView.layer.masksToBounds = YES;
    
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    if (afterDelay > 0) {
        // 指定时间之后再消失
        [hud hideAnimated:YES afterDelay:afterDelay];
    }else {
        //针对"正在提交"图标旋转动效动画
        
        //绕Z轴中心旋转
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        // 起始角度
        animation.fromValue = [NSNumber numberWithFloat:0.0];
        // 终止角度
        animation.toValue = [NSNumber numberWithFloat:2*M_PI];
        // 动画组
        CAAnimationGroup *group = [CAAnimationGroup animation];
        // 执行时间
        group.beginTime = CACurrentMediaTime();
        // 持续时间
        group.duration = 1.0;
        // 重复次数
        group.repeatCount = INFINITY;
        // 动画结束是否恢复原状
        group.removedOnCompletion = YES;
        // 动画组
        group.animations = [NSArray arrayWithObjects:animation, nil];
        // 添加动画
        [iconImgView.layer addAnimation:group forKey:@"group"];
    }
}


@end
