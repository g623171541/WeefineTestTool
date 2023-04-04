//
//  DataBaseManager.m
//  Test
//
//  Created by 谷幸东 on 2021/3/4.
//  Copyright © 2021 ILFE. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDB.h"

@interface DataBaseManager()
@property (nonatomic,strong) FMDatabase * db;
@end

@implementation DataBaseManager

+ (instancetype)sharedFMDataBase{
    static DataBaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataBaseManager alloc]init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // 得到数据库
        NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *filename = [doc stringByAppendingPathComponent:@"device.sqlite"];
        // 当数据库文件不存在时会自动创建一个数据库文件。
        if (!_db) {
            _db = [FMDatabase databaseWithPath:filename];
        }
        // 为数据库设置缓存，提高查询效率
        [_db setShouldCacheStatements:YES];
    }
    return self;
}

// 创建表
- (void)createTable:(NSString *)tableName{
    // 打开数据库
    if ([_db open]) {
        if (![_db tableExists:tableName]) {
            // 创建表
            NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ ('ID' INTEGER PRIMARY KEY AUTOINCREMENT, 'mac' TEXT NOT NULL, 'name' TEXT NOT NULL, 'software' TEXT NOT NULL, 'hardware' TEXT NOT NULL, 'product' TEXT NOT NULL, 'sensor' INTEGER NOT NULL, 'shutter' INTEGER NOT NULL, 'top' INTEGER NOT NULL, 'bottom' INTEGER NOT NULL, 'left' INTEGER NOT NULL, 'right' INTEGER NOT NULL, 'leak' INTEGER NOT NULL, 'result' INTEGER NOT NULL, 'time' TEXT NOT NULL)", tableName];
            [_db executeUpdate:sql];
        }else{
            NSLog(@"已经有表了，不需要重新添加");
        }
    }
    //关闭数据库
    [_db close];
}

/// 获取数据库所有表名
-(NSArray *)getAllTableNames{
    NSMutableArray *tableNames = [NSMutableArray array];
    // 打开数据库
    if ([_db open]) {
        // 根据请求参数查询数据
        FMResultSet *resultSet = [_db executeQuery:@"SELECT * FROM sqlite_master where type='table' order by name desc"];
        // 遍历查询结果
        while (resultSet.next) {
            NSString *str1 = [resultSet stringForColumnIndex:1];
            [tableNames addObject:str1];
        }
    }
    
    // 关闭数据库
    [_db close];
    if ([tableNames.lastObject isEqualToString:@"sqlite_sequence"]) {
        [tableNames removeLastObject];
    }
    return [tableNames copy];
}

/// 表中插入单条数据
/// @param model 测试结果模型
/// @param tableName 表名
- (void)insertModel:(DeviceInfoModel *)model tableName:(NSString *)tableName {
    /**
     增删改查中 除了查询（executeQuery），其余操作都用（executeUpdate）
     //1.sql语句中跟columnname 绑定的value 用 ？表示，不加‘’，可选参数是对象类型如：NSString，不是基本数据结构类型如：int，方法自动匹配对象类型
     - (BOOL)executeUpdate:(NSString*)sql, ...;
     //2.sql语句中跟columnname 绑定的value 用%@／%d表示，不加‘’
     - (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
     //3.sql语句中跟columnname 绑定的value 用 ？表示的地方依次用 (NSArray *)arguments 对应的数据替代
     - (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
     //4.同3 ，区别在于多一个error指针，记录更新失败
     - (BOOL)executeUpdate:(NSString*)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
     //5.同3，区别在于用 ？ 表示的地方依次用(NSDictionary *)arguments中对应的数据替代
     - (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;
     - (BOOL)executeUpdate:(NSString*)sql withVAList: (va_list)args;
     */
    //0.直接sql语句
    //    BOOL result = [db executeUpdate:@"insert into 't_student' (ID,name,phone,score) values(110,'x1','11',83)"];
    //1.
    //    BOOL result = [db executeUpdate:@"insert into 't_student'(ID,name,phone,score) values(?,?,?,?)",@111,@"x2",@"12",@23];
    //2.
    //    BOOL result = [db executeUpdateWithFormat:@"insert into 't_student' (ID,name,phone,score) values(%d,%@,%@,%d)",112,@"x3",@"13",43];
    //3.
    if ([_db open]) {
        NSString *sqStr = [NSString stringWithFormat:@"insert into '%@' (mac, name, software, hardware, product, sensor, shutter, top, bottom, left, right, leak, result, time) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)", tableName];
        [_db executeUpdate:sqStr withArgumentsInArray:@[model.mac, model.name, model.software, model.hardware, model.product, @(model.sensor), @(model.shutter), @(model.top), @(model.bottom), @(model.left), @(model.right), @(model.leak), @(model.result), model.time]];
    }
    [_db close];
}

/// 获取表中的数据
/// @param tableName 表名
- (NSDictionary *)getData:(NSString *)tableName{
    /**
     FMResultSet根据column name获取对应数据的方法
     intForColumn：
     longForColumn：
     longLongIntForColumn：
     boolForColumn：
     doubleForColumn：
     stringForColumn：
     dataForColumn：
     dataNoCopyForColumn：
     UTF8StringForColumnIndex：
     objectForColumn：
     */
    [_db open];
    //0.直接sql语句
    //    FMResultSet *result = [db executeQuery:@"select * from 't_student' where ID = 110"];
    //1.
    //    FMResultSet *result = [db executeQuery:@"select *from 't_student' where ID = ?",@111];
    //2.
    //    FMResultSet *result = [db executeQueryWithFormat:@"select * from 't_student' where ID = %d",112];
    //3.
    
    NSString *sqStr = [NSString stringWithFormat:@"select * from '%@' order by id",tableName];
    FMResultSet *result = [_db executeQuery:sqStr];
    
    //4
    //    FMResultSet *result = [db executeQuery:@"select * from 't_sutdent' where ID = ?" withParameterDictionary:@{@"ID":@114}];
    NSMutableArray *timeArrM = [NSMutableArray array];
    NSMutableArray *depthArrM = [NSMutableArray array];
    NSMutableArray *temperatureArrM = [NSMutableArray array];
    while ([result next]) {
        [timeArrM addObject:[result stringForColumn:@"time"]];
        [temperatureArrM addObject:@([result doubleForColumn:@"temperature"])];
        [depthArrM addObject:@([result doubleForColumn:@"depth"])];
    }
    [_db close];
    
    NSDictionary *dic = @{
        @"time":timeArrM,
        @"depth":depthArrM,
        @"temperature":temperatureArrM
    };
    return dic;
}

// 删除表
-(void)deleteTable:(NSString *)tableName{
    if ([_db open]) {
        NSString *sqStr = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
        BOOL success = [_db executeUpdate:sqStr];
        if (success) {
            NSLog(@"删除成功%@",tableName);
        }
    }
    [_db close];
}

// 获取表中多少条数据
- (int )getDataCount:(NSString *)tableName{
    int count = 0;
    if ([_db open]) {
        NSString *sqStr = [NSString stringWithFormat:@"select count(id) from %@",tableName];
        count = [_db intForQuery:sqStr];
    }
    [_db close];
    return count;
}

#pragma mark - 时间戳转化为字符转 0000-00-00 00:00:00
+ (NSString *)time_timestampToString:(NSInteger )timestamp{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* string = [dateFormat stringFromDate:confromTimesp];
    return string;
}

#pragma mark - 字符串时间—>时间戳
+ (NSString *)time_StringToTimestamp:(NSString *)theTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateTodo = [formatter dateFromString:theTime];
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[dateTodo timeIntervalSince1970]];
    return timeSp;
}

@end
