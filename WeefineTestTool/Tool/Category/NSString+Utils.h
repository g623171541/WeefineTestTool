//
//  NSString+HETAdditions.h
//  HETSDK
//
//  Created by JiangJun on 15/3/31.
//  Copyright (c) 2015年 JiangJun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (BOOL)isMobileNumber:(NSString *)mobileNum;//手机号验证


+(BOOL)isValidEmail:(NSString *)emailStr;//检查邮箱是否有效

+ (BOOL)isValidPassword:(NSString *)passwordStr;//检查密码格式是否正确
+ (BOOL)isValidStrongPassword:(NSString *)passwordStr;//加强版密码格式校验

+ (BOOL)isContainsEmoji:(NSString *)string;//检查时候包含emoji

+ (NSString *)removeEmojiString:(NSString *)string;//去除emoji

///10进制数字转16进制
+ (NSString *)getHexByDecimal:(long long int)tmpid;

#pragma mark - 字符串编码长度
/// 获取字符的字节长度（GBK编码）
- (NSUInteger)characterLengthGBK;
/// 获取字符的字节长度（UTF8编码）
- (NSUInteger)characterLengthUTF8;

///10进制数字转16进制(不足位补0)
+ (NSString *)getHexByDecimal:(long long int)decimal WithLength:(NSUInteger)length;

///2进制转16进制
- (NSString *)getHexByBinary;

/// 16进制转2进制
- (NSString *)getBinaryByHex;

/// 补位的方法（前面补0）
/// @param length 补完之后的总长度
- (NSString *)append0StringTotalLength:(NSInteger )length;
/// 补位的方法（后面补0）
/// @param length 补完之后的总长度
- (NSString *)insert0StringTotalLength:(NSInteger )length;

///字符串转2进制
- (NSData *)stringToData;

///10进制转2进制
+ (NSString *)getBinaryByDecimal:(int )decimal;

///16进制string转string
- (NSString *)hexStringToString;

///string转16进制
- (NSString *)stringToHexString;

/// 十六进制字符串转10进制long
- (unsigned long long)convertHexToDecimal;

+ (NSString *)getTimeStrWithSec:(NSInteger)sec;

+ (NSString *)getTimeStrMinWithSec:(NSInteger)sec;

/// 通过秒获取时间(时,分)
+ (NSString *)getTimeStrHourMinWithSec:(NSInteger)sec;

/// 四舍五入到指定位置
+ (NSString *)rounding:(double)value afterPoint:(int)position;

/// 截取字符串
/// - Parameters:
///   - begin: 开始字节位置 需大于0
///   - byte: 字节长度
- (NSString *)substringWithBeginByte:(NSInteger)begin byte:(NSInteger)byte;

/// 获取相应长度的十六进制数据
/// - Parameters:
///   - bytes: 数据源
///   - length: 长度
+ (NSString *)getStringFromHexByte:(Byte *)bytes length:(int)length;

@end
