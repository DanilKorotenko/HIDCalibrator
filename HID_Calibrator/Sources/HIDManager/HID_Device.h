//
//  HIDDevice.h
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/2/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/hid/IOHIDLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface HID_Device : NSObject

+ (instancetype)createWithDeviceRef:(IOHIDDeviceRef)aDeviceRef;

@property(readonly) NSString *manufacturer;
@property(readonly) NSString *product;

@property(readonly) NSInteger vendorID;
@property(readonly) NSString *vendorName;
@property(readonly) NSInteger productID;
@property(readonly) NSString *productName;

@end

NS_ASSUME_NONNULL_END
