//
//  HIDManager.m
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/2/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import "HID_Manager.h"

#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hidsystem/IOHIDLib.h>

#import "HID_Device.h"
#import "HID_Error.h"

#import "HID_Calibrator_Common.h"

NSString * const kHID_DeviceAdded = @"HIDDeviceAdded";
NSString * const kHID_DeviceRemoved = @"HIDDeviceRemoved";

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef);
static void Handle_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef);


@implementation HID_Manager
{
    IOHIDManagerRef _ioHIDManagerRef;
}

+ (HID_Manager *)sharedManager
{
    static HID_Manager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedManager = [[HID_Manager alloc] init];
    });
    return sharedManager;
}

- (void)dealloc
{
    if (_ioHIDManagerRef != NULL)
    {
        CFRelease(_ioHIDManagerRef);
    }
}

- (BOOL)start:(NSError **)anError
{
    BOOL result = YES;

    do
    {
        // create the manager
        IOOptionBits ioOptionBits = kIOHIDManagerOptionNone;
        //IOOptionBits ioOptionBits = kIOHIDManagerOptionUsePersistentProperties;
        //IOOptionBits ioOptionBits = kIOHIDManagerOptionUsePersistentProperties | kIOHIDManagerOptionDoNotLoadProperties;
        _ioHIDManagerRef = IOHIDManagerCreate(kCFAllocatorDefault, ioOptionBits);
        if (!_ioHIDManagerRef)
        {
            NSLog(@"%s: Could not create IOHIDManager.\n", __PRETTY_FUNCTION__);
            break;  // THROW
        }

        // register our matching & removal callbacks
        IOHIDManagerRegisterDeviceMatchingCallback(_ioHIDManagerRef, Handle_DeviceMatchingCallback, (void*)self);
        IOHIDManagerRegisterDeviceRemovalCallback(_ioHIDManagerRef, Handle_DeviceRemovalCallback, (void*)self);

        // schedule us with the run loop
        IOHIDManagerScheduleWithRunLoop(_ioHIDManagerRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

        // setup matching dictionary
        IOHIDManagerSetDeviceMatching(_ioHIDManagerRef, NULL);

        // open it
        IOReturn tIOReturn = IOHIDManagerOpen(_ioHIDManagerRef, kIOHIDOptionsTypeNone);
        if (kIOReturnSuccess != tIOReturn)
        {
            result = NO;
            if (anError != NULL)
            {
                *anError = [HID_Error errorForCode:tIOReturn];
            }
            NSLog(@"%s: IOHIDManagerOpen error: 0x%08u",
                    __PRETTY_FUNCTION__,
                    tIOReturn);
            break;
        }

        NSLogDebug(@"IOHIDManager (%p) creaded and opened!", (void *) _ioHIDManagerRef);
    } while (false);

    return result;
}

- (void)stop
{
    NSLogDebug();
#if false
    IOHIDManagerSaveToPropertyDomain(gIOHIDManagerRef,
                                     kCFPreferencesCurrentApplication,
                                     kCFPreferencesCurrentUser,
                                     kCFPreferencesCurrentHost,
                                     kIOHIDOptionsTypeNone);
	return (IOHIDManagerClose(gIOHIDManagerRef, kIOHIDOptionsTypeNone));
#endif
}

- (BOOL)checkAccess:(NSError **)anError
{
    IOHIDAccessType accessType = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent);
    if (accessType != kIOHIDAccessTypeGranted)
    {
        if (anError != NULL)
        {
            *anError = [HID_Error accessDenied];
        }
        return NO;
    }
    return YES;
}

- (BOOL)requestAccess
{
    return IOHIDRequestAccess(kIOHIDRequestTypeListenEvent);
}

#pragma mark -

- (void)deviceAdded:(HID_Device *)aDevice
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHID_DeviceAdded object:aDevice];
}

- (void)deviceRemoved:(HID_Device *)aDevice
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHID_DeviceRemoved object:aDevice];
}

@end

//
// this is called once for each connected device
//
static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender,
    IOHIDDeviceRef inIOHIDDeviceRef)
{
    HID_Device *device = [HID_Device createWithDeviceRef:inIOHIDDeviceRef];

    NSLog(@"device added: %@", device);

    [(__bridge HID_Manager *)inContext deviceAdded:device];
}

//
// this is called once for each disconnected device
//
static void Handle_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender,
    IOHIDDeviceRef inIOHIDDeviceRef)
{
    HID_Device *device = [HID_Device createWithDeviceRef:inIOHIDDeviceRef];

    NSLog(@"device removed: %@", device);

    [(__bridge HID_Manager *)inContext deviceRemoved:device];
}
