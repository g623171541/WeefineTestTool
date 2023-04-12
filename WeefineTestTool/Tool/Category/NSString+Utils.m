//
//  NSString+HETAdditions.m
//  HETSDK
//
//  Created by JiangJun on 15/3/31.
//  Copyright (c) 2015年 JiangJun. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Utils.h"
#import <objc/runtime.h>

@implementation NSString (Utils)


+(BOOL)isValidPassword:(NSString *)passwordStr
{
    NSString * regex = @"^[A-Za-z0-9]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:passwordStr];
    return isMatch;
}
+ (BOOL)isValidStrongPassword:(NSString *)passwordStr{
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:passwordStr];
    return isMatch;
}
//检查邮箱是否有效
+(BOOL)isValidEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

//检查时候包含emoji
+ (BOOL)isContainsEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    isEomji = YES;
                }
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                isEomji = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                isEomji = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                isEomji = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                isEomji = YES;
            }
            if (!isEomji && substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                if (ls == 0x20e3) {
                    isEomji = YES;
                }
            }
        }
    }];
    return isEomji;
}

+ (NSString *)removeEmojiString:(NSString *)string{
    __block NSMutableString *str = [NSMutableString string];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![NSString isContainsEmoji:substring]) {
            [str appendString:substring];
        }
    }];
    return [str copy];
}


+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    
    NSString *newMobile = [[NSUserDefaults standardUserDefaults] valueForKey:@"kMobileRegular"];
    if (newMobile.length == 0) {
        newMobile = @"^((17[0-9])|(13[0-9])|(15[0-3,5-9])|(18[0-9])|(199)|(198)|(166)|(145)|(147))\\d{8}$";
    }
    NSPredicate *regextesnewMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", newMobile];
    return [regextesnewMobile evaluateWithObject:mobileNum];
}

/// 十进制转十六进制
/// @param tmpid 十进制
+ (NSString *)getHexByDecimal:(long long int)tmpid {
    NSString *nLetterValue;
    NSString *str = @"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig = tmpid%16;
        tmpid = tmpid/16;
        switch (ttmpig) {
            case 10:
                nLetterValue = @"A"; break;
            case 11:
                nLetterValue = @"B"; break;
            case 12:
                nLetterValue = @"C"; break;
            case 13:
                nLetterValue = @"D"; break;
            case 14:
                nLetterValue = @"E"; break;
            case 15:
                nLetterValue = @"F"; break;
            default:
                nLetterValue = [[NSString alloc] initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    // 转偶数
    if (str.length % 2) {
        str = [NSString stringWithFormat:@"0%@", str];
    }
    return str;
}

#pragma mark - 字符串编码长度
- (NSUInteger)characterLengthGBK {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [self characterLengthWithEncoding:encoding];
}

- (NSUInteger)characterLengthUTF8 {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    return [self characterLengthWithEncoding:encoding];
}

- (NSUInteger)characterLengthWithEncoding:(NSStringEncoding )encoding {
    NSUInteger strLength = 0;
    char *p = (char *)[self cStringUsingEncoding:encoding];
    NSUInteger lengthOfBytes = [self lengthOfBytesUsingEncoding:encoding];
    for (int i=0; i<lengthOfBytes; i++) {
        if (*p) {
            strLength++;
        }
        p++;
    }
    return strLength;
}

///  十进制转十六进制,总长度不足补0
+ (NSString *)getHexByDecimal:(long long int)decimal WithLength:(NSUInteger)length {
    NSString* subString = [NSString getHexByDecimal:decimal];
    NSUInteger moreL = length - subString.length;
    if (moreL>0) {
        for (int i = 0; i<moreL; i++) {
            subString = [NSString stringWithFormat:@"0%@",subString];
        }
    }
    return subString;
}

/// 二进制转十六进制
- (NSString *)getHexByBinary {
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    NSString *binary = self;
    if (self.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - self.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}


/// 十六进制转二进制
- (NSString *)getBinaryByHex {
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[self length]; i++) {
        NSString *key = [self substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}



/// 补位的方法（前面补0）
/// @param length 补完之后的总长度
- (NSString *)insert0StringTotalLength:(NSInteger )length {
    NSMutableString *nullStr = [[NSMutableString alloc] initWithString:@""];
    if (length-self.length > 0) {
        for (int i = 0; i< (length-self.length); i++) {
            [nullStr appendString:@"0"];
        }
    }
    return [NSString stringWithFormat:@"%@%@", nullStr, self];
}

/// 补位的方法（后面补0）
/// @param length 补完之后的总长度
- (NSString *)append0StringTotalLength:(NSInteger )length {
    NSMutableString *nullStr = [[NSMutableString alloc] initWithString:@""];
    if (length-self.length > 0) {
        for (int i = 0; i< (length-self.length); i++) {
            [nullStr appendString:@"0"];
        }
    }
    return [NSString stringWithFormat:@"%@%@", self, nullStr];
}


/// 字符串转二进制
- (NSData *)stringToData {
    if (!self || self.length == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([self length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [self length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [self substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

/// 十进制转换为二进制
/// @param decimal 十进制数
+ (NSString *)getBinaryByDecimal:(int )decimal {
    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%d", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 8 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}

/// 16进制string转string
- (NSString *)hexStringToString {
    char *myBuffer = (char *)malloc((int)[self length] / 2 + 1);
    bzero(myBuffer, [self length] / 2 + 1);
    for (int i = 0; i < [self length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [self substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    return unicodeString;
}

///string转16进制
- (NSString *)stringToHexString {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if ([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        } else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

/// 十六进制字符串转10进制long
- (unsigned long long)convertHexToDecimal {
    unsigned long long decimal = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner scanHexLongLong:&decimal];
    return decimal;
}

+ (NSString *)getTimeStrWithSec:(NSInteger)sec {
    long seconds = sec % 60;
    long minutes = (sec / 60) % 60;
    long hours = sec / 3600;
    NSString *timeStr = hours == 0 ? @"" : [NSString stringWithFormat:@"%ld时", hours];
    timeStr = minutes == 0 ? timeStr : [NSString stringWithFormat:@"%@%ld分", timeStr, minutes];
    timeStr = seconds == 0 ? timeStr : [NSString stringWithFormat:@"%@%ld秒", timeStr, seconds];
    return timeStr;
}

+ (NSString *)getTimeStrMinWithSec:(NSInteger)sec {
    if (sec < 60) {
        return @"0分钟";
    }
    long minutes = sec / 60;
    return [NSString stringWithFormat:@"%ld分钟", minutes];
}

+ (NSString *)getTimeStrHourMinWithSec:(NSInteger)sec {
    long minutes = (sec / 60) % 60;
    long hours = sec / 3600;
    NSString *timeStr = hours == 0 ? @"" : [NSString stringWithFormat:@"%ld时", hours];
    timeStr = minutes == 0 ? timeStr : [NSString stringWithFormat:@"%@%ld分", timeStr, minutes];
    return timeStr;
}


+ (NSString *)rounding:(double)value afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                      scale:position raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:value];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

/// 截取字符串
/// - Parameters:
///   - begin: 开始字节位置 需大于0
///   - byte: 字节长度
- (NSString *)substringWithBeginByte:(NSInteger)begin byte:(NSInteger)byte {
    if (self.length >= (begin + byte - 1) * 2) {
        return [self substringWithRange:NSMakeRange((begin - 1) * 2, byte * 2)];
    } else if (self.length >= begin * 2) {
        return [self substringWithRange:NSMakeRange((begin - 1) * 2, self.length - begin * 2)];
    }
    return @"";
}

/// 获取相应长度的十六进制数据
/// - Parameters:
///   - bytes: 数据源
///   - length: 长度
+ (NSString *)getStringFromHexByte:(Byte *)bytes length:(int)length {
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i=0; i<length; i++) {
        Byte byte = bytes[i];
        NSString *value = [NSString stringWithFormat:@"%02x",byte];
        [str appendString:value];
    }
    return str;
}

@end


