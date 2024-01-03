//
//        File: HID_CalibratorAppDelegate.m
//    Abstract: Delegate for HID_Calibrator sample application
//     Version: 2.0
//    
//    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//    Inc. ("Apple") in consideration of your agreement to the following
//    terms, and your use, installation, modification or redistribution of
//    this Apple software constitutes acceptance of these terms.  If you do
//    not agree with these terms, please do not use, install, modify or
//    redistribute this Apple software.
//    
//    In consideration of your agreement to abide by the following terms, and
//    subject to these terms, Apple grants you a personal, non-exclusive
//    license, under Apple's copyrights in this original Apple software (the
//    "Apple Software"), to use, reproduce, modify and redistribute the Apple
//    Software, with or without modifications, in source and/or binary forms;
//    provided that if you redistribute the Apple Software in its entirety and
//    without modifications, you must retain this notice and the following
//    text and disclaimers in all such redistributions of the Apple Software.
//    Neither the name, trademarks, service marks or logos of Apple Inc. may
//    be used to endorse or promote products derived from the Apple Software
//    without specific prior written permission from Apple.  Except as
//    expressly stated in this notice, no other rights or licenses, express or
//    implied, are granted by Apple herein, including but not limited to any
//    patent rights that may be infringed by your derivative works or by other
//    works in which the Apple Software may be incorporated.
//    
//    The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//    MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//    THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//    OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//    
//    IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//    INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//    MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//    AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//    STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//    POSSIBILITY OF SUCH DAMAGE.
//    
//    Copyright (C) 2014 Apple Inc. All Rights Reserved.
//    

//*****************************************************
#pragma mark - includes & imports
//-----------------------------------------------------

#include "HID_Utilities_External.h"

#import "IOHIDDeviceWindowCtrl.h"

#import "HID_CalibratorAppDelegate.h"

#import "HID_Calibrator_Common.h"

#import "HIDManager/HID_Manager.h"
#import "HIDManager/HID_Device.h"
#import "HIDManager/HID_Error.h"

//*****************************************************
#pragma mark - local ( static ) function prototypes
//-----------------------------------------------------


//*****************************************************
#pragma mark - private class interface
//-----------------------------------------------------

@interface HID_CalibratorAppDelegate ()

@property (strong) NSMutableArray * windowControllers;

@end

//*****************************************************
#pragma mark - public implementation
//-----------------------------------------------------

@implementation HID_CalibratorAppDelegate

- (void)applicationDidFinishLaunching: (NSNotification *) aNotification
{
    self.windowControllers = [[NSMutableArray alloc] init];
    NSError *error = nil;

    if (![[HID_Manager sharedManager] checkAccess:&error])
    {
        if ([[HID_Manager sharedManager] requestAccess])
        {
            if (![[HID_Manager sharedManager] start:&error])
            {
                [NSApp presentError:error];
                [NSApp terminate:self];
            }
        }
        else
        {
            [NSApp presentError:[HID_Error accessDenied]];
            [NSApp terminate:self];
        }
    }
    else
    {
        if (![[HID_Manager sharedManager] start:&error])
        {
            [NSApp presentError:error];
            [NSApp terminate:self];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAdded:)
        name:kHID_DeviceAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemoved:)
        name:kHID_DeviceRemoved object:nil];
}

- (void)applicationWillTerminate: (NSNotification *) notification
{
    [[HID_Manager sharedManager] stop];
}

#pragma mark -

- (void)deviceAdded:(NSNotification *)aNotification
{
    HID_Device *device = [aNotification object];

    IOHIDDeviceWindowCtrl * ioHIDDeviceWindowCtrl = [self windowControllerForDevice:device];

    if (nil == ioHIDDeviceWindowCtrl)
    {
        IOHIDDeviceWindowCtrl *ioHIDDeviceWindowCtrl = [[IOHIDDeviceWindowCtrl alloc] initWithHID_Device:device];
        [self.windowControllers addObject:ioHIDDeviceWindowCtrl];
        [ioHIDDeviceWindowCtrl showWindow:self];
    }
}

- (void)deviceRemoved:(NSNotification *)aNotification
{
    HID_Device *device = [aNotification object];

    IOHIDDeviceWindowCtrl * ioHIDDeviceWindowCtrl = [self windowControllerForDevice:device];

    if (ioHIDDeviceWindowCtrl)
    {
        [self.windowControllers removeObject:ioHIDDeviceWindowCtrl];
        [[ioHIDDeviceWindowCtrl window] close];
    }
}

- (IOHIDDeviceWindowCtrl *)windowControllerForDevice:(HID_Device *)aDevice
{
    IOHIDDeviceWindowCtrl *result = nil;
    for (IOHIDDeviceWindowCtrl * ioHIDDeviceWindowCtrl in self.windowControllers)
    {
        if ([ioHIDDeviceWindowCtrl.device isEqual:aDevice])
        {
            result = ioHIDDeviceWindowCtrl;
            break;
        }
    }
    return result;
}

@end
