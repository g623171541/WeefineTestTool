//
//  NSString+Category.m
//  TongQiuZhiNeng
//
//  Created by LL on 16/3/4.
//  Copyright © 2016年 cstqzn. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Category)

/**
 *  获取相应长度的十六进制数据
 *
 *  @param bytes  数据源
 *  @param length 长度
 *
 *  @return 字符串
 */
+ (NSString *)getStringFromHexByte:(Byte *)bytes length:(int)length {
    
    NSMutableString *str=[[NSMutableString alloc]init];
    
    for (int i=0; i<length; i++) {
        
        Byte byte=bytes[i];
        
        NSString *value=[NSString stringWithFormat:@"%02x",byte];
        
        [str appendString:value];
    }
    
    return str;
}

/**
 *  截取字符串
 *
 *  @param begin 开始字节位置 需大于0
 *  @param byte 字节长度
 *
 *  @return 字符串
 */
- (NSString *)substringWithBeginByte:(NSInteger)begin byte:(NSInteger)byte {

    if (self.length >= (begin + byte - 1) * 2) {
    
        return [self substringWithRange:NSMakeRange((begin - 1) * 2, byte * 2)];
    } else if (self.length >= begin * 2) {
        
        return [self substringWithRange:NSMakeRange((begin - 1) * 2, self.length - begin * 2)];
    }
    
    return @"";
}

//16进制转2进制
- (NSString *)getBinaryByhex {
    
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
    
    NSString *binaryString = @"";
    
    for (int i=0; i<[self length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [self substringWithRange:rage];
        
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
    }
    
    return binaryString;
}

//10进制转16进制
+ (NSString *)ToHex:(long long int)tmpid {
    
    NSString *nLetterValue;
    
    NSString *str =@"";
    
    long long int ttmpig;
    
    for (int i = 0; i<9; i++) {
        
        ttmpig=tmpid%16;
        
        tmpid=tmpid/16;
        
        switch (ttmpig) {
                
            case 10:
                
                nLetterValue =@"A";break;
                
            case 11:
                
                nLetterValue =@"B";break;
                
            case 12:
                
                nLetterValue =@"C";break;
                
            case 13:
                
                nLetterValue =@"D";break;
                
            case 14:
                
                nLetterValue =@"E";break;
                
            case 15:
                
                nLetterValue =@"F";break;
                
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
        }
        
        str = [nLetterValue stringByAppendingString:str];
        
        if (tmpid == 0) {
            
            break;
        }
    }  
    
    return str;
}

@end
