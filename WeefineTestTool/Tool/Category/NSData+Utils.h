//
//  NSData+Utils.h
//  Massage
//
//  Created by paddy on 2022/5/28.
//  Copyright © 2022 HeT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Utils)

/// 将16进制NSData去掉尖括号转为字符串，如<A020> -> @"A020"
- (NSString *)convertToHexStr;

/// 将16进制NSData转为Int
- (int32_t )convertToInt;

/// 将NSData转为Float
/// - Parameter dataIsBigEndian: NSData是否是大端格式
- (float )convertBigEndianDataToFloat:(BOOL)dataIsBigEndian;

- (UInt8) calibrate_crc8;
- (UInt16) calibrate_crc16;
- (UInt16) calibrate_bcc16;

@end

NS_ASSUME_NONNULL_END
