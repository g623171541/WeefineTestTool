//
//  MAUserDefaults.m
//  ILIFERobot
//
//  Created by paddygu on 2019/5/29.
//  Copyright © 2019 ILIFE. All rights reserved.
//

#import "MAUserDefaults.h"

@implementation MAUserDefaults

+(void)saveToLocal:(id)object forKey:(NSString *)key{
    if(object == nil){
        [self removeObjectFromLocal:key];
        return;
    }
    
    //可以在这里添加加密算法，对数据进行加密
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:object forKey:key];
    //判断是否存储成功
    BOOL isFinish = [userDefaults synchronize];
    if (isFinish) {
        NSLog(@"userDefaults存储成功 ---> {key:%@,value:%@}",key,object);
    }else{
        NSLog(@"userDefaults存储失败 ---> {key:%@,value:%@}",key,object);
    }
}


+(id)getObjectFromLocal:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //可以添加解密算法再返回
    return [userDefaults objectForKey:key];
}

+(void)removeObjectFromLocal:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    NSLog(@"删除本地【%@】成功",key);
}


//存BOOL类型的值
+(void)saveBOOLToLocal:(BOOL)yesORno forKey:(NSString *)key{
    //可以在这里添加加密算法，对数据进行加密
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:yesORno forKey:key];
    //判断是否存储成功
    BOOL isFinish = [userDefaults synchronize];
    if (isFinish) {
        NSLog(@"userDefaults存储成功 ---> {key:%@,value:%d}",key,yesORno);
    }else{
        NSLog(@"userDefaults存储失败 ---> {key:%@,value:%d}",key,yesORno);
    }
}

//取BOOL类型的值
+(BOOL)getBOOLFromLocal:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //可以添加解密算法再返回
    return [userDefaults boolForKey:key];
}


@end
