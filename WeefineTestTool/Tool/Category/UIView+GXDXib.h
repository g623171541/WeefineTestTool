//
//  UIView+GXDXib.h
//  Yudo
//
//  Created by paddygu on 2020/9/24.
//  Copyright © 2020 yudo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 宏定义的作用是可以通过keypath动态看到效果，实时性，动态刷新
IB_DESIGNABLE

@interface UIView (GXDXib)

// 边框宽度
@property (nonatomic,assign) IBInspectable CGFloat borderWidth;
// 边框颜色
@property (nonatomic,assign) IBInspectable UIColor *borderColor;
// 边框圆角
@property (nonatomic,assign) IBInspectable CGFloat cornerRadius;
// 边框阴影半径
@property (nonatomic,assign) IBInspectable CGFloat shadowRadius;
// 阴影透明度
@property (nonatomic,assign) IBInspectable CGFloat shadowOpacity;
// 阴影颜色
@property (nonatomic,assign) IBInspectable UIColor *shadowColor;
// 阴影偏移
@property (nonatomic,assign) IBInspectable CGSize shadowOffset;
// 左上角圆角
@property (nonatomic,assign) IBInspectable CGFloat cornerTopLeft;
// 右上角圆角
@property (nonatomic,assign) IBInspectable CGFloat cornerTopRight;
// 左下角圆角
@property (nonatomic,assign) IBInspectable CGFloat cornerBottomLeft;
// 右下角圆角
@property (nonatomic,assign) IBInspectable CGFloat cornerBottomRight;
// 左边圆角（上下）
@property (nonatomic,assign) IBInspectable CGFloat cornerLeft;
// 右边圆角（上下）
@property (nonatomic,assign) IBInspectable CGFloat cornerRight;
// 上边圆角（左右）
@property (nonatomic,assign) IBInspectable CGFloat cornerTop;
// 下边圆角（左右）
@property (nonatomic,assign) IBInspectable CGFloat cornerBottom;

+ (instancetype)viewFromXib;

@end

NS_ASSUME_NONNULL_END
