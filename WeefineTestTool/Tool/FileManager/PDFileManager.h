//
//  PDFileManager.h
//  PhotoDive
//
//  Created by paddy on 2022/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDFileManager : NSObject

/// 视频水印文件路径数组
@property (nonatomic, strong) NSMutableArray *watermarkFileArrM;

+ (instancetype)shareInstance;

/// 写入文件
/// @param content 写入文件的内容
/// @param fileName 文件名称
+ (BOOL)writeToLocal:(NSString *)content fileName:(NSString *)fileName;

/// 获取文件内容
/// @param fileName 文件名
- (NSArray <NSString *>*)getContentWithFileName:(NSString *)fileName;

/// 删除水印文件
/// @param fileName 文件名称
+ (void)deleteWatermarkFile:(NSString *)fileName;

/// 获取视频缓存地址
+ (NSString *)getVideoPathCache;

/// 获取视频名称（带后缀）
+ (NSString *)getVideoName;


@end

NS_ASSUME_NONNULL_END
