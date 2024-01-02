//
//  HIDManager.h
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/2/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kHID_DeviceAdded;
extern NSString * const kHID_DeviceRemoved;

@interface HID_Manager : NSObject

+ (HID_Manager *)sharedManager;

- (BOOL)checkAccess:(NSError **)anError;

- (BOOL)start:(NSError **)anError;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
