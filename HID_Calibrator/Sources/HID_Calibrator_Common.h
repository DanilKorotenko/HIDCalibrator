//
//  HID_Calibrator_Common.h
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/6/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#ifndef HID_Calibrator_Common_h
#define HID_Calibrator_Common_h
//
// Prefix header for all source files of the 'HID_Calibrator' target in the 'HID_Calibrator' project
//

#ifdef __OBJC__
	#import <Cocoa/Cocoa.h>
#endif

#if DEBUG_ASSERT_PRODUCTION_CODE
#define NSLogDebug(format, ...)
#else
#define NSLogDebug(format, ...) \
NSLog(@"<%s:%d> %s, " format, \
strrchr("/" __FILE__, '/') + 1, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__)
#endif // if DEBUG_ASSERT_PRODUCTION_CODE

#endif /* HID_Calibrator_Common_h */
