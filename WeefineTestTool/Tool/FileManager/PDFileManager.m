//
//  PDFileManager.m
//  PhotoDive
//
//  Created by paddy on 2022/4/9.
//

#import "PDFileManager.h"

@implementation PDFileManager

+ (instancetype)shareInstance{
    static PDFileManager *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[PDFileManager alloc] init];
    });
    return manager;
}

+ (BOOL)writeToLocal:(NSString *)content fileName:(NSString *)fileName {
    // 获取到对应的文件夹
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    documentsDir = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit = [fileManager fileExistsAtPath:documentsDir];
    // 文件是否存在
    if (!isExit) {
        if ([fileManager createFileAtPath:documentsDir contents:nil attributes:nil]) {
            BOOL res = [content writeToFile:documentsDir atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"写入水印日志 %@ --- %@", res ? @"成功✅" : @"失败❌", fileName);
            return res;
        }else {
            return NO;
        }
    }else {
        BOOL res = [content writeToFile:documentsDir atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return res;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.watermarkFileArrM = [NSMutableArray array];
    }
    return self;
}

/// 获取文件夹下所有txt文件
/// @param path 文件路径
- (void)showAllFileWithPath:(NSString *) path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllFileWithPath:subPath];
            }
        }else{
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".txt"]) {
                [_watermarkFileArrM addObject:[fileName substringToIndex:fileName.length-4]];
            }
        }
    }else{
        NSLog(@"this path is not exist!");
    }
}

- (NSMutableArray *)watermarkFileArrM {
    _watermarkFileArrM = [NSMutableArray array];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [self showAllFileWithPath:documentsDir];
    return _watermarkFileArrM;
}

/// 获取文件内容
/// @param fileName 文件名加后缀
- (NSArray <NSString *>*)getContentWithFileName:(NSString *)fileName {
    // 获取到对应的文件
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    documentsDir = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit = [fileManager fileExistsAtPath:documentsDir];
    // 文件是否存在
    if (isExit) {
        NSError *error;
        NSString *content = [NSString stringWithContentsOfFile:documentsDir encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            NSLog(@"文件读取成功: %@",content);
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
        if (content.length == 0 || [content isKindOfClass:[NSNull class]] || content == nil) {
            NSLog(@"文件中无数据 %@", fileName);
            return nil;
        }else{
            NSArray *arr = [content componentsSeparatedByString:@"|"];
            return arr;
        }
    }else {
        NSLog(@"文件不存在 %@", fileName);
        return nil;
    }
}

/// 删除水印文件
/// @param fileName 文件名称
+ (void)deleteWatermarkFile:(NSString *)fileName {
    // 获取到对应的文件
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    documentsDir = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit = [fileManager fileExistsAtPath:documentsDir];
    if (isExit) {
        NSError *error;
        [fileManager removeItemAtPath:documentsDir error:&error];
        if (error) {
            NSLog(@"❌ 删除水印文件失败：%@", documentsDir);
        }else {
            NSLog(@"✅ 删除水印文件成功：%@", documentsDir);
        }
    }
}

/// 获取视频缓存地址
+ (NSString *)getVideoPathCache {
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingString:@"videos"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if (!existed) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoCache;
}

/// 获取视频名称（带后缀）
+ (NSString *)getVideoName {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:now];
    NSString *timeStr = [formatter stringFromDate:nowDate];
    return timeStr;
}



@end
