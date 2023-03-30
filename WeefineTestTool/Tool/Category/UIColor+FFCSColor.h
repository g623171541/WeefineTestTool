//
//  UIColor+FFCSColor.h
//  southEastCarApp
//
//  Created by 卓宝坤 on 2017/3/23.
//  Copyright © 2017年 souest-motor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FFCSColor)

+ (UIColor *)colorWithHex:(NSString *)hexString alpha:(CGFloat)alphaValue;
+ (UIColor *)colorWithHex:(NSString *)hexString;


/// 获取当前UIColor对象里的透明色值：透明通道的色值，值范围为0.0-1.0
- (CGFloat)fsp_alpha;


@end
