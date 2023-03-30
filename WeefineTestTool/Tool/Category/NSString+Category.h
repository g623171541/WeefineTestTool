//
//  NSString+Category.h
//  TongQiuZhiNeng
//
//  Created by LL on 16/3/4.
//  Copyright © 2016年 cstqzn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

/**
 *  获取相应长度的十六进制数据
 *
 *  @param bytes  数据源
 *  @param length 长度
 *
 *  @return 字符串
 */
+ (NSString *)getStringFromHexByte:(Byte *)bytes length:(int)length;

//MD5加密
- (NSString *)encrypt16MD5;

/**
 *  截取字符串
 *
 *  @param begin 开始字节位置 需大于0
 *  @param byte 字节长度
 *
 *  @return 字符串
 */
- (NSString *)substringWithBeginByte:(NSInteger)begin byte:(NSInteger)byte;

//16进制转2进制
- (NSString *)getBinaryByhex;

//10进制转16进制
+ (NSString *)ToHex:(long long int)tmpid;

@end
