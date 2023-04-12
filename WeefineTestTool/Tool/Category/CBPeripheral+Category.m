//
//  CBPeripheral+Category.m
//  WeefineTestTool
//
//  Created by paddy on 2023/4/12.
//

#import "CBPeripheral+Category.h"
#import <objc/runtime.h>

@implementation CBPeripheral (Category)

- (NSString *)manufacturer {
    return objc_getAssociatedObject(self,@selector(manufacturer)) ;
}
- (void)setManufacturer:(NSString *)manufacturer {
    objc_setAssociatedObject(self, @selector(manufacturer), manufacturer,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)mac {
    return objc_getAssociatedObject(self,@selector(mac)) ;
}
- (void)setMac:(NSString *)mac {
    objc_setAssociatedObject(self, @selector(mac),mac,OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber *)deviceType {
    return objc_getAssociatedObject(self,@selector(deviceType)) ;
}
- (void)setDeviceType:(NSNumber *)deviceType {
    objc_setAssociatedObject(self, @selector(deviceType),deviceType,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)deviceSubType {
    return objc_getAssociatedObject(self,@selector(deviceSubType)) ;
}
- (void)setDeviceSubType:(NSNumber *)deviceSubType {
    objc_setAssociatedObject(self, @selector(deviceSubType),deviceSubType,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)productId {
    return objc_getAssociatedObject(self,@selector(productId)) ;
}
- (void)setProductId:(NSNumber *)productId {
    objc_setAssociatedObject(self, @selector(productId), productId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)alreadyBind {
    return objc_getAssociatedObject(self,@selector(alreadyBind)) ;
}
- (void)setAlreadyBind:(NSNumber *)alreadyBind {
    objc_setAssociatedObject(self, @selector(alreadyBind), alreadyBind, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)canConnectNetwork {
    return objc_getAssociatedObject(self,@selector(canConnectNetwork)) ;
}
- (void)setCanConnectNetwork:(NSNumber *)canConnectNetwork {
    objc_setAssociatedObject(self, @selector(canConnectNetwork),canConnectNetwork,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)rssi {
    return objc_getAssociatedObject(self,@selector(rssi)) ;
}
- (void)setRssi:(NSNumber *)rssi {
    objc_setAssociatedObject(self, @selector(rssi),rssi,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
