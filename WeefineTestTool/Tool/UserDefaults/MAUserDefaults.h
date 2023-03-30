//
//  MAUserDefaults.h
//  ILIFERobot
//
//  Created by paddygu on 2019/5/29.
//  Copyright © 2019 ILIFE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MAUserDefaults : NSObject

//UserDefaults存值
+(void)saveToLocal:(id)object forKey:(NSString *)key;

//UserDefaults取值
+(id)getObjectFromLocal:(NSString *)key;

//UserDefaults删除值
+(void)removeObjectFromLocal:(NSString *)key;

//存BOOL类型的值
+(void)saveBOOLToLocal:(BOOL)yesORno forKey:(NSString *)key;

//取BOOL类型的值
+(BOOL)getBOOLFromLocal:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
