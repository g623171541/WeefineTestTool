//
//  DataBaseManager.h
//  Test
//
//  Created by 谷幸东 on 2021/3/4.
//  Copyright © 2021 ILFE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataBaseManager : NSObject

+ (instancetype)sharedFMDataBase;

/// 创建表
/// @param tableName 表名
- (void)createTable:(NSString *)tableName;

/// 获取数据库所有表名
- (NSArray *)getAllTableNames;

/// 表中插入单条数据
/// @param tableName 表名
/// @param depth 深度
/// @param temperature 温度
/// @param time 时间（格式：2021-03-04 19:04:38）
- (void)insert:(NSString *)tableName depth:(float )depth temperature:(float )temperature time:(NSString *)time;

/// 表中插入所所有数据（事务操作）
/// @param dataArr 数据源
/// @param tableName 表名
- (void)insertAllData:(NSString *)tableName data:(NSArray *)dataArr;

/// 获取表中的数据
/// @param tableName 表名
- (NSDictionary *)getData:(NSString *)tableName;

/// 删除表
/// @param tableName 表名
- (void)deleteTable:(NSString *)tableName;

/// 获取表中多少条数据
/// @param tableName 表名
- (int )getDataCount:(NSString *)tableName;

#pragma mark - 时间戳转化为字符转 0000-00-00 00:00:00
+ (NSString *)time_timestampToString:(NSInteger )timestamp;

#pragma mark - 字符串时间—>时间戳
+ (NSString *)time_StringToTimestamp:(NSString *)theTime;

@end

NS_ASSUME_NONNULL_END
