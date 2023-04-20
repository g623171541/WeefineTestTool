//
//  DataBaseManager.h
//  Test
//
//  Created by 谷幸东 on 2021/3/4.
//  Copyright © 2021 ILFE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

// excel文件名和格式
#define kCSVFileName    @"Weefine.csv"
// 数据库名字
#define kSQLFileName    @"device.sqlite"
// 表名
#define kTableName      @"device"

@interface DataBaseManager : NSObject

+ (instancetype)sharedFMDataBase;

/// 创建表
/// @param tableName 表名
- (void)createTable:(NSString *)tableName;

/// 获取数据库所有表名
- (NSArray *)getAllTableNames;

/// 表中插入单条数据
/// @param model 测试结果模型
/// @param tableName 表名
- (void)insertModel:(DeviceInfoModel *)model tableName:(NSString *)tableName;

/// 获取表中的数据
/// @param tableName 表名
- (NSDictionary *)getData:(NSString *)tableName;

/// 删除表
/// @param tableName 表名
- (void)deleteTable:(NSString *)tableName;

/// 获取表中多少条数据
/// @param tableName 表名
- (int )getDataCount:(NSString *)tableName;

#pragma mark - 时间戳
/// 时间戳转化为字符转 0000-00-00 00:00:00
+ (NSString *)time_timestampToString:(NSInteger )timestamp;

/// 字符串时间—>时间戳
+ (NSString *)time_StringToTimestamp:(NSString *)theTime;

#pragma mark - 数据库导出成Excel表格
- (NSString *)exportExcelFileWithTableName:(NSString *)tableName;



@end

NS_ASSUME_NONNULL_END
