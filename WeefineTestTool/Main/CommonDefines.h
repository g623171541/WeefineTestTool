//
//  CommonDefines.h
//  Yudo
//
//  Created by fushp on 2019/5/13.
//  Copyright © 2019年 卓宝坤. All rights reserved.
//

#ifndef CommonDefines_h
#define CommonDefines_h

#define UmengAppKey                 @"61a5d159e0f9bb492b73e1ae"
#define kServiceUUID                @"8653000A-43E6-47B7-9CB0-5FC21D4AE340"
#define kCharacteristicUUIDWrite    @"8653000C-43E6-47B7-9CB0-5FC21D4AE340"
#define kCharacteristicUUIDNotify   @"8653000B-43E6-47B7-9CB0-5FC21D4AE340"

#pragma mark - APP名字和版本号
#define APP_NAME    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_BUNDLE  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
// ios系统版本
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define iOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)
#define kSystemVersion [[UIDevice currentDevice]systemVersion]
#define SYSTEM_VERSION_GRETER_THAN(v)   ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// 横屏状态
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

//NSLOG
#define NSLog(format, ...)  NSLog((@"\t文件名:%s" "\t行号:%d" "\t方法名:%s" "打印结果:" format"\n"), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,__FUNCTION__,  ##__VA_ARGS__)
//#define NSLog(format,...) printf("文件名:%s\t行号:%d\t结果:%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])
//#define NSLog(format,...) printf("%s 需要加8小时\t文件名:%s\t行号:%d\t结果:%s\n",[[[NSDate date] description] UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

//是否为iPhone X 系列  （消除Xcode10上警告）
#define isIphoneX_Series \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
//导航栏高度
#define NavBar_Height 44
//TabBar的高度
#define TabBar_Height  (isIphoneX_Series? 83 : 49)
//状态栏高度
#define Status_Height (isIphoneX_Series?44:20)
//顶部导航栏+状态栏高度
#define SafeAreaTopHeight (isIphoneX_Series ? 88 : 64)
//底部 安全高度
#define Bottom_Safe_Height (isIphoneX_Series?34:0)


#pragma mark - 颜色
#define kColorBlack             [UIColor colorWithHex:@"000000"]
#define kColorWhite             [UIColor colorWithHex:@"FFFFFF"]
#define kColorGreen             [UIColor colorWithHex:@"00AF00"]

#define kColorGrey1             [UIColor colorWithHex:@"EFEFEF"]    // 页面背景颜色
#define kColorGrey2             [UIColor colorWithHex:@"666666"]
#define kColorGrey3             [UIColor colorWithHex:@"D8D8D8"]
#define kColorGrey4             [UIColor colorWithHex:@"EBEBEB"]
#define kColorGrey5             [UIColor colorWithHex:@"000000" alpha:0.1]

#define kColorRed1              [UIColor colorWithHex:@"FF0000"]
#define kColorRed2              [UIColor colorWithHex:@"FF6464"]
// 字体颜色蓝色
#define kColorBlue1              [UIColor colorWithHex:@"00C3FF"]
// 背景色蓝色
#define kColorBlue2              [UIColor colorWithHex:@"37ADDD"]

#pragma mark - 字符串
#define PD_camera                       @"PD_camera"                    // 镜头设置：广角超广角长焦
#define PD_camerasInDevice              @"PD_camerasInDevice"           // 该手机拥有的镜头数组
#define PD_watermark                    @"PD_watermark"                 // 水印开关
#define PD_pictureResolution            @"PD_pictureResolution"         // 拍照分辨率
#define PD_iso                          @"PD_iso"                       // ISO
#define PD_whiteBalance                 @"PD_whiteBalance"              // 白平衡
#define PD_exposureCompensation         @"PD_exposureCompensation"      // 曝光补偿
#define PD_videoResolution              @"PD_videoResolution"           // 视频分辨率
#define PD_availableVideoResolution     @"PD_availableVideoResolution"  // 摄像头支持的视频分辨率：4k60 / 4k30 / 1080p60 / 1080p30 / 720p60
#define PD_soundRecording               @"PD_soundRecording"            // 声音录制
#define PD_powerSaveTime                @"PD_powerSaveTime"             // 省电模式：多久后息屏
#define PD_maxDepthWaring               @"PD_maxDepthWaring"            // 深度报警，如果深度报警值>200则代表没有传感器
#define PD_Notify_RestartCamera         @"PD_Notify_RestartCamera"      // 通知：重启摄像头
#define PD_Notify_OpenWaterMark         @"PD_Notify_OpenWaterMark"      // 通知：水印开关

#pragma mark - 视频帧率
#define PD_video_4K60                   @"4K 60FPS"
#define PD_video_4K30                   @"4K 30FPS"
#define PD_video_1080p60                @"1080p 60FPS"
#define PD_video_1080p30                @"1080p 30FPS"
#define PD_video_720p60                 @"720p 60FPS"

#pragma mark - 强弱引用
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;
#define DefineWeakSelf __weak __typeof(self) weakSelf = self
//安全使用block
#define KBlockSafe(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

#define LocalizedString(string) NSLocalizedString(string, nil)

#pragma mark - 变量-编译相关

/// 判断当前是否debug编译模式
#ifdef DEBUG
#define IS_DEBUG YES
#else
#define IS_DEBUG NO
#endif



#pragma mark - Clang

#define ArgumentToString(macro) #macro
#define ClangWarningConcat(warning_name) ArgumentToString(clang diagnostic ignored warning_name)

/// 参数可直接传入 clang 的 warning 名，warning 列表参考：https://clang.llvm.org/docs/DiagnosticsReference.html
#define BeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(ClangWarningConcat(#warningName))
#define EndIgnoreClangWarning _Pragma("clang diagnostic pop")

#define BeginIgnorePerformSelectorLeaksWarning BeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define EndIgnorePerformSelectorLeaksWarning EndIgnoreClangWarning

#define BeginIgnoreAvailabilityWarning BeginIgnoreClangWarning(-Wpartial-availability)
#define EndIgnoreAvailabilityWarning EndIgnoreClangWarning

#define BeginIgnoreDeprecatedWarning BeginIgnoreClangWarning(-Wdeprecated-declarations)
#define EndIgnoreDeprecatedWarning EndIgnoreClangWarning


#pragma mark - 方法-创建器

#define UIImageMake(img) [UIImage imageNamed:img]

/// 使用文件名(不带后缀名，仅限png)创建一个UIImage对象，不会被系统缓存，用于不被复用的图片，特别是大图
#define UIImageMakeWithFile(name) UIImageMakeWithFileAndSuffix(name, @"png")
#define UIImageMakeWithFileAndSuffix(name, suffix) [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", [[NSBundle mainBundle] resourcePath], name, suffix]]

typedef void(^YDBlock)(void);
typedef void(^YDObjectBlock)(id obj);

#pragma mark - 判断是否为空
//字符串是否为空
#define isEmptyString(str) (([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1) ? YES : NO )
//数组是否为空
#define isEmptyArray(array) ((array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0) ? YES : NO)
//字典是否为空
#define isEmptyDictionary(dic) ((dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0) ? YES : NO)
//是否是空对象
#define isEmptyObj(_object) ((_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0)) ? YES : NO)


#pragma mark - 数学计算

#define AngleWithDegrees(deg) (M_PI * (deg) / 180.0)


#pragma mark - 动画

#define QMUIViewAnimationOptionsCurveOut (7<<16)
#define QMUIViewAnimationOptionsCurveIn (8<<16)


#pragma mark - 单例
#undef    AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once(&once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#pragma mark - 消息宏
#define YD_PostNotice(NOTICE, OBJECT)\
[[NSNotificationCenter defaultCenter] postNotificationName:NOTICE object:OBJECT];

#define YD_PostInfoNotice(NOTICE, OBJECT, USERINFO)\
[[NSNotificationCenter defaultCenter] postNotificationName:NOTICE object:OBJECT userInfo:USERINFO];

#define YD_Add_Until_Notice(NOTICE)\
[[[NSNotificationCenter defaultCenter] rac_addObserverForName:NOTICE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x)

#define YD_Add_Still_Notice(NOTICE)\
[[NSNotificationCenter defaultCenter] rac_addObserverForName:NOTICE object:nil] subscribeNext:^(NSNotification * _Nullable x)

#define YD_Btn_Click(OBSERVER)\
[OBSERVER rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x)

#pragma mark - 页面跳转
#define YD_PopViewControllerAnimated(animate)\
[self.navigationController popViewControllerAnimated:animate];

#define YD_pushViewControllerAnimated(vc, animate)\
[self.navigationController pushViewController:vc animated:animate];

#endif /* CommonDefines_h */
