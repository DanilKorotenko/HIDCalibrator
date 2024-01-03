//
//  IOHIDDeviceWindowCtrl.h
//  HID_Calibrator
//
//  Created by George Warner on 3/26/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "HID_Utilities_External.h"
#import "HIDManager/HID_Device.h"

@interface IOHIDDeviceWindowCtrl : NSWindowController

@property (assign, nonatomic, readwrite) IOHIDDeviceRef _IOHIDDeviceRef;
@property (unsafe_unretained, nonatomic, readwrite) NSArray * _IOHIDElementModels;
@property (unsafe_unretained, readonly) NSString * name;

- (instancetype)initWithHID_Device:(HID_Device *)aDevice;

@property(readonly) HID_Device *device;

@end
