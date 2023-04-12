//
//  CBPeripheral+Category.h
//  WeefineTestTool
//
//  Created by paddy on 2023/4/12.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (Category)

// 广播数据总长度：20Bytes

/// 设备的厂商信息
@property (nonatomic, strong) NSString *manufacturer;
/// 设备的mac地址
@property (nonatomic, strong) NSString *mac;
/// 设备的大类
@property (nonatomic, strong) NSNumber *deviceType;
/// 设备的小类
@property (nonatomic, strong) NSNumber *deviceSubType;
/// 设备的产品ID
@property (nonatomic, strong) NSNumber *productId;
/// 是否已经被绑定 0未绑定 其他为已绑定
@property (nonatomic, strong) NSNumber *alreadyBind;
/// 是否可被配网 0不可配网 其他可配网
@property (nonatomic, strong) NSNumber *canConnectNetwork;
/// 设备的信号
@property (nonatomic, strong) NSNumber *rssi;

@end

NS_ASSUME_NONNULL_END
