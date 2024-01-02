//
//  HIDError.h
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/2/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HID_Error : NSObject

+ (NSError *)accessDenied;

+ (NSError *)errorForCode:(IOReturn)aCode;

@end

NS_ASSUME_NONNULL_END
