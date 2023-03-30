//
//  UIView+GXDXib.m
//  Yudo
//
//  Created by paddygu on 2020/9/24.
//  Copyright © 2020 yudo. All rights reserved.
//

#import "UIView+GXDXib.h"

@implementation UIView (GXDXib)

//@dynamic告诉编译器,属性的setter与getter方法由用户自己实现，不自动生成。
@dynamic borderWidth;
@dynamic borderColor;
@dynamic cornerRadius;
@dynamic shadowRadius;
@dynamic shadowOpacity;
@dynamic shadowColor;
@dynamic shadowOffset;
@dynamic cornerTopLeft;
@dynamic cornerTopRight;
@dynamic cornerBottomLeft;
@dynamic cornerBottomRight;
@dynamic cornerLeft;
@dynamic cornerRight;
@dynamic cornerTop;
@dynamic cornerBottom;

// 边框宽度
- (void)setBorderWidth:(CGFloat)borderWidth{
    if (borderWidth < 0) {
        return;
    }
    self.layer.borderWidth = borderWidth;
}
// 边框颜色
- (void)setBorderColor:(UIColor *)borderColor{
    self.layer.borderColor = borderColor.CGColor;
}
// 边框圆角
- (void)setCornerRadius:(CGFloat)cornerRadius{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}
// 边框阴影半径
- (void)setShadowRadius:(CGFloat)shadowRadius{
    self.layer.shadowRadius = shadowRadius;
}
// 阴影透明度
- (void)setShadowOpacity:(CGFloat)shadowOpacity{
    self.layer.shadowOpacity = shadowOpacity;
}
// 阴影颜色
- (void)setShadowColor:(UIColor *)shadowColor{
    // 必须要设置，否则阴影出不来
    self.clipsToBounds = NO;
    self.layer.shadowColor = shadowColor.CGColor;
}
// 阴影偏移
- (void)setShadowOffset:(CGSize)shadowOffset{
    self.layer.shadowOffset = shadowOffset;
}

// 左上角圆角
- (void)setCornerTopLeft:(CGFloat)cornerTopLeft{
    [self setOneCorner:cornerTopLeft position:UIRectCornerTopLeft];
}
// 右上角圆角
- (void)setCornerTopRight:(CGFloat)cornerTopRight{
    [self setOneCorner:cornerTopRight position:UIRectCornerTopRight];
}
// 左下角圆角
- (void)setCornerBottomLeft:(CGFloat)cornerBottomLeft{
    [self setOneCorner:cornerBottomLeft position:UIRectCornerBottomLeft];
}
// 右下角圆角
- (void)setCornerBottomRight:(CGFloat)cornerBottomRight{
    [self setOneCorner:cornerBottomRight position:UIRectCornerBottomRight];
}
// 左边圆角（上下）
- (void)setCornerLeft:(CGFloat)cornerLeft{
    [self setOneCorner:cornerLeft position:UIRectCornerTopLeft | UIRectCornerBottomLeft];
}
// 右边圆角（上下）
- (void)setCornerRight:(CGFloat)cornerRight{
    [self setOneCorner:cornerRight position:UIRectCornerTopRight | UIRectCornerBottomRight];
}
// 上边圆角（左右）
- (void)setCornerTop:(CGFloat)cornerTop{
    [self setOneCorner:cornerTop position:UIRectCornerTopLeft | UIRectCornerTopRight];
}
// 下边圆角（左右）
- (void)setCornerBottom:(CGFloat)cornerBottom{
    [self setOneCorner:cornerBottom position:UIRectCornerBottomLeft | UIRectCornerBottomRight];
}




// 设置圆角大小和位置
-(void)setOneCorner:(CGFloat )radius position:(UIRectCorner)rectCorner{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

#pragma mark - Xib instance
+ (instancetype)viewFromXib {
    NSBundle *bundle = [NSBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:bundle];
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    __block UIView *returnView = nil;
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id view = obj;
        if ([view isKindOfClass:self]) {
            *stop = YES;
            returnView = view;
            return ;
        }
    }];
    return returnView;
}

@end
