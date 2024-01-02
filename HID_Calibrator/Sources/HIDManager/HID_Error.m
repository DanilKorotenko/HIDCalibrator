//
//  HIDError.m
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/2/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import "HID_Error.h"

typedef enum : NSUInteger
{
    HID_ErrorCodeSuccess = 0,
    HID_ErrorCodeAccessDenied,

} HID_ErrorCode;

@implementation HID_Error

+ (NSError *)accessDenied
{
    return [NSError errorWithDomain:NSCocoaErrorDomain code:HID_ErrorCodeAccessDenied
        userInfo:@{NSLocalizedDescriptionKey: @"HID Access Denied"}];
}


+ (NSError *)errorForCode:(IOReturn)aCode
{
    NSError *result = nil;

    switch (aCode)
    {

        default:
            break;
    }

    return result;
}

@end
