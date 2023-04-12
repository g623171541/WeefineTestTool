//
//  NSData+Utils.m
//  Massage
//
//  Created by paddy on 2022/5/28.
//  Copyright © 2022 HeT. All rights reserved.
//

#import "NSData+Utils.h"

@implementation NSData (Utils)

/// 将16进制NSData去掉尖括号转为字符串，如<A020> -> @"A020"
- (NSString *)convertToHexStr {
    if (!self || [self length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[self length]];
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

/// 将16进制NSData转为Int
- (int32_t )convertToInt {
    // NSData转int
    int32_t value = 0;
    if (self == nil) {
        return value;
    }
    if (self.length == 1) {
        [self getBytes:&value length:sizeof(value)];
    }else {
        // 这个转发有问题 <01e0> 转成了 31514625
//        int32_t bytes = 0;
//        [self getBytes:&bytes length:sizeof(bytes)];
//        bytes = OSSwapBigToHostInt32(bytes);
//        memcpy(&value, &bytes, sizeof(bytes));
        Byte *byte = (Byte *)[self bytes];
        for(int i=0; i<self.length; i++) {
            value += (byte[i] << (self.length - i - 1) * 8);
        }
    }
    return value;
}

/// 将NSData转为Float
/// - Parameter dataIsBigEndian: NSData是否是大端格式
- (float )convertBigEndianDataToFloat:(BOOL)dataIsBigEndian {
    float value = 0;
    if (dataIsBigEndian) {
        // 大端格式的NSData转换
        NSMutableData *dataM = [NSMutableData data];
        for (long i=self.length-1; i>=0; i--) {
            [dataM appendData:[self subdataWithRange:NSMakeRange(i, 1)]];
        }
        value = *(float *)dataM.bytes;
    } else {
        // 小端格式转换
        value = *(float *)self.bytes;
    }
    return value;
}

- (UInt8)calibrate_crc8 {
    static    unsigned char     crc;
    static    unsigned char     crcbuff;
    static    unsigned char     i;
    
    crc = 0;
    const uint8_t *data = self.bytes;
    NSUInteger length = self.length;
    while( length-- )
    {
        crcbuff = *data ++;
        
        for(i = 0; i < 8; i++)
        {
            if( (crc ^ crcbuff) & 0x01 )
            {
                crc ^= 0x18;
                crc >>= 1;
                crc |= 0x80;
            }
            else
            {
                crc >>= 1;
            }
            crcbuff >>= 1;
        }
    }
    return crc;
}

-(UInt16) calibrate_crc16 {
    char j;
    int i;
    unsigned short retCrc16;
    retCrc16 = 0xffff;
    const uint8_t *data = self.bytes;
    for(i=0;i<self.length;i++)
    {
        retCrc16 ^=((*data++)&0x000000ff);
        for(j = 0;j<8;j++){
            if(retCrc16&0x01)
            {
                retCrc16=(retCrc16>>1)^0x8408;
            }
            else{
                retCrc16>>=0x01;
            }
        }
    }
    return ~retCrc16;

}
- (UInt16) calibrate_bcc16 {
    int i=0;
    unsigned short bdata = 0;
    const uint8_t *data = self.bytes;
    while (i<self.length) {
        bdata = bdata ^ data[i];
        i++;
    }
    return bdata;
}

@end
