//
//  HIDDevice.m
//  HID_Calibrator
//
//  Created by Danil Korotenko on 1/2/24.
//  Copyright © 2024 Apple Inc. All rights reserved.
//

#import "HID_Device.h"

static NSString *const kIOHIDDevice_TransactionKey =    @"DeviceTransactionRef";
static NSString *const kIOHIDDevice_QueueKey =          @"DeviceQueueRef";

@interface HID_Device ()

@property (strong) NSMutableDictionary *properties;

@end

@implementation HID_Device
{
    IOHIDDeviceRef _deviceRef;
}

+ (instancetype)createWithDeviceRef:(IOHIDDeviceRef)aDeviceRef
{
    return [[HID_Device alloc] initWithIOHIDDevice:aDeviceRef];
}

- (instancetype)initWithIOHIDDevice:(IOHIDDeviceRef)aDeviceRef
{
    self = [super init];
    if (self)
    {
        if (aDeviceRef == NULL)
        {
            return nil;
        }

        if (CFGetTypeID(aDeviceRef) != IOHIDDeviceGetTypeID())
        {
            return nil;
        }

        self.properties = [NSMutableDictionary dictionary];

        _deviceRef = (IOHIDDeviceRef)CFRetain(aDeviceRef);
    }
    return self;
}

- (NSString *)description
{
    NSDictionary *propDict =
    @{
        @"manufacturer" :   self.manufacturer ? @"<none>" : self.manufacturer,
        @"product":         self.product ? @"<none>" : self.product,
        @"vendorID":        @(self.vendorID),
        //HIDGetVendorNameFromVendorID
        @"productID":       @(self.productID)
        //HIDGetProductNameFromVendorProductID
    };

//    uint32_t usagePage = IOHIDDevice_GetUsagePage(inIOHIDDeviceRef);
//    uint32_t usage = IOHIDDevice_GetUsage(inIOHIDDeviceRef);
//    if (!usagePage || !usage)
//    {
//        usagePage = IOHIDDevice_GetPrimaryUsagePage(inIOHIDDeviceRef);
//        usage = IOHIDDevice_GetPrimaryUsage(inIOHIDDeviceRef);
//    }
//
//    printf("usage: 0x%04X:0x%04X, ", usagePage, usage);
//
//#if true
//    tCFStringRef = HIDCopyUsageName(usagePage, usage);
//    if (tCFStringRef)
//    {
////        verify(CFStringGetCString(tCFStringRef, cstring, sizeof(cstring), kCFStringEncodingUTF8));
//        printf("\"%s\", ", cstring);
//        CFRelease(tCFStringRef);
//    }
//
//#endif // if 1
//
//#if true
//    tCFStringRef = IOHIDDevice_GetTransport(inIOHIDDeviceRef);
//    if (tCFStringRef)
//    {
////        verify(CFStringGetCString(tCFStringRef, cstring, sizeof(cstring), kCFStringEncodingUTF8));
//        printf("Transport: \"%s\", ", cstring);
//    }
//
//    uint32_t vendorIDSource = IOHIDDevice_GetVendorIDSource(inIOHIDDeviceRef);
//    if (vendorIDSource)
//    {
//        printf("VendorIDSource: %u, ", vendorIDSource);
//    }
//
//    uint32_t version = IOHIDDevice_GetVersionNumber(inIOHIDDeviceRef);
//    if (version)
//    {
//        printf("version: %u, ", version);
//    }
//
//    tCFStringRef = IOHIDDevice_GetSerialNumber(inIOHIDDeviceRef);
//    if (tCFStringRef)
//    {
////        verify(CFStringGetCString(tCFStringRef, cstring, sizeof(cstring), kCFStringEncodingUTF8));
//        printf("SerialNumber: \"%s\", ", cstring);
//    }
//
//    uint32_t country = IOHIDDevice_GetCountryCode(inIOHIDDeviceRef);
//    if (country) {
//        printf("CountryCode: %u, ", country);
//    }
//
//    uint32_t locationID = IOHIDDevice_GetLocationID(inIOHIDDeviceRef);
//    if (locationID) {
//        printf("locationID: 0x%08X, ", locationID);
//    }
//#if false
//    CFArrayRef pairs = IOHIDDevice_GetUsagePairs(inIOHIDDeviceRef);
//    if (pairs) {
//        CFIndex idx, cnt = CFArrayGetCount(pairs);
//        for (idx = 0; idx < cnt; idx++) {
//            const void *pair = CFArrayGetValueAtIndex(pairs, idx);
//            CFShow(pair);
//        }
//    }
//#endif // if false
//    uint32_t maxInputReportSize = IOHIDDevice_GetMaxInputReportSize(inIOHIDDeviceRef);
//    if (maxInputReportSize) {
//        printf("MaxInputReportSize: %u, ", maxInputReportSize);
//    }
//
//    uint32_t maxOutputReportSize = IOHIDDevice_GetMaxOutputReportSize(inIOHIDDeviceRef);
//    if (maxOutputReportSize) {
//        printf("MaxOutputReportSize: %u, ", maxOutputReportSize);
//    }
//
//    uint32_t maxFeatureReportSize = IOHIDDevice_GetMaxFeatureReportSize(inIOHIDDeviceRef);
//    if (maxFeatureReportSize) {
//        printf("MaxFeatureReportSize: %u, ", maxOutputReportSize);
//    }
//
//    uint32_t reportInterval = IOHIDDevice_GetReportInterval(inIOHIDDeviceRef);
//    if (reportInterval) {
//        printf("ReportInterval: %u, ", reportInterval);
//    }
//
//    IOHIDQueueRef queueRef = IOHIDDevice_GetQueue(inIOHIDDeviceRef);
//    if (queueRef) {
//        printf("queue: %p, ", queueRef);
//    }
//
//    IOHIDTransactionRef transactionRef = IOHIDDevice_GetTransaction(inIOHIDDeviceRef);
//    if (transactionRef) {
//        printf("transaction: %p, ", transactionRef);
//    }
//#endif // if 1
//    printf("}\n");
//    fflush(stdout);
//}   // HIDDumpDeviceInfo

    return [propDict description];
}

- (void)dealloc
{
    if(_deviceRef != NULL)
    {
        CFRelease(_deviceRef);
    }
}

#pragma mark -

-(NSString *)manufacturer
{
    NSString *val = [self.properties objectForKey:@kIOHIDManufacturerKey];
    if (!val)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDManufacturerKey));
        if (tCFTypeRef)
        {
            val = (__bridge NSString *)tCFTypeRef;
            [self.properties setObject:val forKey:@kIOHIDManufacturerKey];
        }
    }
    return val;
}

-(NSString *)product
{
    NSString *val = [self.properties objectForKey:@kIOHIDProductKey];
    if (!val)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDProductKey));
        if (tCFTypeRef)
        {
            val = (__bridge NSString *)tCFTypeRef;
            [self.properties setObject:val forKey:@kIOHIDProductKey];
        }
    }
    return val;
}

- (NSInteger)vendorID
{
    NSNumber *val = [self.properties objectForKey:@kIOHIDVendorIDKey];
    if (!val)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDVendorIDKey));
        if (tCFTypeRef)
        {
            val = (__bridge NSNumber *)tCFTypeRef;
            [self.properties setObject:val forKey:@kIOHIDVendorIDKey];
        }
    }
    return val.integerValue;
}

- (NSInteger)productID
{
    NSNumber *val = [self.properties objectForKey:@kIOHIDProductIDKey];
    if (!val)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDProductIDKey));
        if (tCFTypeRef)
        {
            val = (__bridge NSNumber *)tCFTypeRef;
            [self.properties setObject:val forKey:@kIOHIDProductIDKey];
        }
    }
    return val.integerValue;
}

@end

// *****************************************************
#pragma mark - local (static) function prototypes
// -----------------------------------------------------

//static Boolean IOHIDDevice_GetPtrProperty(IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey, void **outValue);
//static void IOHIDDevice_SetPtrProperty(IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey, void *inValue);

// *************************************************************************
//


// *************************************************************************
//
// IOHIDDevice_GetTransport(inIOHIDDeviceRef)
//
// Purpose:	get the Transport CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	CFStringRef - the Transport for this device
//

//CFStringRef IOHIDDevice_GetTransport(IOHIDDeviceRef inIOHIDDeviceRef) {
//    assert(IOHIDDeviceGetTypeID() == CFGetTypeID(inIOHIDDeviceRef));
//    return (IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDTransportKey)));
//}

// *************************************************************************
//
// IOHIDDevice_GetVendorIDSource(inIOHIDDeviceRef)
//
// Purpose:	get the VendorIDSource for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the VendorIDSource for this device
//

//uint32_t IOHIDDevice_GetVendorIDSource(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDVendorIDSourceKey), &result);
//    return (result);
//} // IOHIDDevice_GetVendorIDSource

// *************************************************************************
//
// IOHIDDevice_GetVersionNumber(inIOHIDDeviceRef)
//
// Purpose:	get the VersionNumber CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the VersionNumber for this device
//

//uint32_t IOHIDDevice_GetVersionNumber(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDVersionNumberKey), &result);
//    return (result);
//} // IOHIDDevice_GetVersionNumber

// *************************************************************************
//
// IOHIDDevice_GetManufacturer(inIOHIDDeviceRef)
//
// Purpose:	get the Manufacturer CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	CFStringRef - the Manufacturer for this device
//


// *************************************************************************
//
// IOHIDDevice_GetProduct(inIOHIDDeviceRef)
//
// Purpose:	get the Product CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	CFStringRef - the Product for this device
//

// *************************************************************************
//
// IOHIDDevice_GetSerialNumber(inIOHIDDeviceRef)
//
// Purpose:	get the SerialNumber CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	CFStringRef - the SerialNumber for this device
//

//CFStringRef IOHIDDevice_GetSerialNumber(IOHIDDeviceRef inIOHIDDeviceRef) {
//    assert(IOHIDDeviceGetTypeID() == CFGetTypeID(inIOHIDDeviceRef));
//    return (IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDSerialNumberKey)));
//}

// *************************************************************************
//
// IOHIDDevice_GetCountryCode(inIOHIDDeviceRef)
//
// Purpose:	get the CountryCode CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the CountryCode for this device
//

//uint32_t IOHIDDevice_GetCountryCode(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDCountryCodeKey), &result);
//    return (result);
//} // IOHIDDevice_GetCountryCode

// *************************************************************************
//
// IOHIDDevice_GetLocationID(inIOHIDDeviceRef)
//
// Purpose:	get the location ID for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the location ID for this device
//

//uint32_t IOHIDDevice_GetLocationID(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDLocationIDKey), &result);
//    return (result);
//}   // IOHIDDevice_GetLocationID

// *************************************************************************
//
// IOHIDDevice_GetUsage(inIOHIDDeviceRef)
//
// Purpose:	get the usage for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the usage for this device
//

//uint32_t IOHIDDevice_GetUsage(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDDeviceUsageKey), &result);
//    return (result);
//} // IOHIDDevice_GetUsage

// *************************************************************************
//
// IOHIDDevice_GetUsagePage(inIOHIDDeviceRef)
//
// Purpose:	get the usage page for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the usage page for this device
//

//uint32_t IOHIDDevice_GetUsagePage(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDDeviceUsagePageKey), &result);
//    return (result);
//}   // IOHIDDevice_GetUsagePage

// *************************************************************************
//
// IOHIDDevice_GetUsagePairs(inIOHIDDeviceRef)
//
// Purpose:	get the UsagePairs CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	CFArrayRef - the UsagePairs for this device
//

//CFArrayRef IOHIDDevice_GetUsagePairs(IOHIDDeviceRef inIOHIDDeviceRef) {
//    assert(IOHIDDeviceGetTypeID() == CFGetTypeID(inIOHIDDeviceRef));
//    return (IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDDeviceUsagePairsKey)));
//}

// *************************************************************************
//
// IOHIDDevice_GetPrimaryUsage(inIOHIDDeviceRef)
//
// Purpose:	get the PrimaryUsage CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the PrimaryUsage for this device
//

//uint32_t IOHIDDevice_GetPrimaryUsage(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDPrimaryUsageKey), &result);
//    return (result);
//} // IOHIDDevice_GetPrimaryUsage

// *************************************************************************
//
// IOHIDDevice_GetPrimaryUsagePage(inIOHIDDeviceRef)
//
// Purpose:	get the PrimaryUsagePage CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the PrimaryUsagePage for this device
//

//uint32_t IOHIDDevice_GetPrimaryUsagePage(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDPrimaryUsagePageKey), &result);
//    return (result);
//} // IOHIDDevice_GetPrimaryUsagePage

// *************************************************************************
//
// IOHIDDevice_GetMaxInputReportSize(inIOHIDDeviceRef)
//
// Purpose:	get the MaxInputReportSize CFString for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t  - the MaxInputReportSize for this device
//

//uint32_t IOHIDDevice_GetMaxInputReportSize(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDMaxInputReportSizeKey), &result);
//    return (result);
//} // IOHIDDevice_GetMaxInputReportSize

// *************************************************************************
//
// IOHIDDevice_GetMaxOutputReportSize(inIOHIDDeviceRef)
//
// Purpose:	get the MaxOutputReportSize for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the MaxOutput for this device
//

//uint32_t IOHIDDevice_GetMaxOutputReportSize(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDMaxOutputReportSizeKey), &result);
//    return (result);
//} // IOHIDDevice_GetMaxOutputReportSize

// *************************************************************************
//
// IOHIDDevice_GetMaxFeatureReportSize(inIOHIDDeviceRef)
//
// Purpose:	get the MaxFeatureReportSize for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the MaxFeatureReportSize for this device
//

//uint32_t IOHIDDevice_GetMaxFeatureReportSize(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDMaxFeatureReportSizeKey), &result);
//    return (result);
//} // IOHIDDevice_GetMaxFeatureReportSize

// *************************************************************************
//
// IOHIDDevice_GetReportInterval(inIOHIDDeviceRef)
//
// Purpose:	get the ReportInterval for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	uint32_t - the ReportInterval for this device
//
#ifndef kIOHIDReportIntervalKey
#define kIOHIDReportIntervalKey    "ReportInterval"
#endif // ifndef kIOHIDReportIntervalKey
//uint32_t IOHIDDevice_GetReportInterval(IOHIDDeviceRef inIOHIDDeviceRef) {
//    uint32_t result = 0;
//
//    (void) IOHIDDevice_GetUInt32Property(inIOHIDDeviceRef, CFSTR(kIOHIDReportIntervalKey), &result);
//    return (result);
//} // IOHIDDevice_GetReportInterval

// *************************************************************************
//
// IOHIDDevice_GetQueue(inIOHIDDeviceRef)
//
// Purpose:	get the Queue for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	IOHIDQueueRef - the Queue for this device
//

//IOHIDQueueRef IOHIDDevice_GetQueue(IOHIDDeviceRef inIOHIDDeviceRef) {
//    IOHIDQueueRef result = 0;
//
//    (void) IOHIDDevice_GetPtrProperty(inIOHIDDeviceRef, (__bridge CFStringRef)kIOHIDDevice_QueueKey, (void *) &result);
//    if (result) {
//        assert(IOHIDQueueGetTypeID() == CFGetTypeID(result));
//    }
//
//    return (result);
//} // IOHIDDevice_GetQueue

// *************************************************************************
//
// IOHIDDevice_SetQueue(inIOHIDDeviceRef, inQueueRef)
//
// Purpose:	Set the Queue for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
// inQueueRef - the Queue reference
//
// Returns:	nothing
//

//void IOHIDDevice_SetQueue(IOHIDDeviceRef inIOHIDDeviceRef, IOHIDQueueRef inQueueRef)
//{
//    IOHIDDevice_SetPtrProperty(inIOHIDDeviceRef, (__bridge CFStringRef)kIOHIDDevice_QueueKey, inQueueRef);
//}

// *************************************************************************
//
// IOHIDDevice_GetTransaction(inIOHIDDeviceRef)
//
// Purpose:	get the Transaction for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
//
// Returns:	IOHIDTransactionRef - the Transaction for this device
//

//IOHIDTransactionRef IOHIDDevice_GetTransaction(IOHIDDeviceRef inIOHIDDeviceRef) {
//    IOHIDTransactionRef result = 0;
//
//    (void) IOHIDDevice_GetPtrProperty(inIOHIDDeviceRef, (__bridge CFStringRef)kIOHIDDevice_TransactionKey, (void *) &result);
//    return (result);
//} // IOHIDDevice_GetTransaction
//
// *************************************************************************
//
// IOHIDDevice_SetTransaction(inIOHIDDeviceRef, inTransactionRef)
//
// Purpose:	Set the Transaction for this device
//
// Inputs:  inIOHIDDeviceRef - the IDHIDDeviceRef for this device
// inTransactionRef - the Transaction reference
//
// Returns:	nothing
//

//void IOHIDDevice_SetTransaction(IOHIDDeviceRef inIOHIDDeviceRef, IOHIDTransactionRef inTransactionRef)
//{
//    IOHIDDevice_SetPtrProperty(inIOHIDDeviceRef, (__bridge CFStringRef)kIOHIDDevice_TransactionKey, inTransactionRef);
//}

// *****************************************************
#pragma mark - local (static) function implementations
// -----------------------------------------------------

// *************************************************************************
//


// *************************************************************************
//
// IOHIDDevice_GetPtrProperty(inIOHIDDeviceRef, inKey, outValue)
//
// Purpose:	convieance function to return a pointer property of a device
//
// Inputs:	inIOHIDDeviceRef		- the device
//			inKey			- CFString for the
//			outValue		- address where to restore the element
// Returns:	the action cookie
//			outValue		- the device
//

//static Boolean IOHIDDevice_GetPtrProperty(IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey, void **outValue) {
//    Boolean result = false;
//    if (inIOHIDDeviceRef) {
//        assert(IOHIDDeviceGetTypeID() == CFGetTypeID(inIOHIDDeviceRef));
//
//        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(inIOHIDDeviceRef, inKey);
//        if (tCFTypeRef) {
//            // if this is a number
//            if (CFNumberGetTypeID() == CFGetTypeID(tCFTypeRef)) {
//                // get it's value
//#ifdef __LP64__
//                result = CFNumberGetValue((CFNumberRef) tCFTypeRef, kCFNumberSInt64Type, outValue);
//#else
//                result = CFNumberGetValue((CFNumberRef) tCFTypeRef, kCFNumberSInt32Type, outValue);
//#endif // ifdef __LP64__
//            }
//        }
//    }
//
//    return (result);
//}   // IOHIDDevice_GetPtrProperty

// *************************************************************************
//
// IOHIDDevice_SetPtrProperty(inIOHIDDeviceRef, inKey, inValue)
//
// Purpose:	convieance function to set a long property of an Device
//
// Inputs:	inIOHIDDeviceRef	- the Device
//			inKey				- CFString for the key
//			inValue				- the value to set it to
// Returns:	nothing
//

//static void IOHIDDevice_SetPtrProperty(IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey, void *inValue) {
//#ifdef __LP64__
//    CFNumberRef tCFNumberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &inValue);
//#else
//    CFNumberRef tCFNumberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &inValue);
//#endif // ifdef __LP64__
//    if (tCFNumberRef) {
//        IOHIDDeviceSetProperty(inIOHIDDeviceRef, inKey, tCFNumberRef);
//        CFRelease(tCFNumberRef);
//    }
//}   // IOHIDDevice_SetPtrProperty

// *****************************************************
