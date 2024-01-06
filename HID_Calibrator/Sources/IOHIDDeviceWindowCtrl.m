//
// IOHIDDeviceWindowCtrl.m
// HID_Calibrator
//
// Created by George Warner on 3/26/11.
// Copyright 2011 Apple Inc. All rights reserved.
//

// ****************************************************
#pragma mark - includes & imports *

// ----------------------------------------------------
#import "IOHIDElementModel.h"

#import "IOHIDDeviceWindowCtrl.h"

#import "HID_Calibrator_Common.h"

// ****************************************************
#pragma mark - local ( static ) function prototypes *
// ----------------------------------------------------

static void Handle_IOHIDValueCallback(void *inContext,
                                      IOReturn inResult,
                                      void *inSender,
                                      IOHIDValueRef inIOHIDValueRef);

// ****************************************************
#pragma mark - private class interface *
// ----------------------------------------------------

@interface IOHIDDeviceWindowCtrl ()
{
@private
    IOHIDDeviceRef _IOHIDDeviceRef;

    __unsafe_unretained NSMutableArray		*_IOHIDElementModels;	// IOHIDElementModel items
    //    __unsafe_unretained IBOutlet NSTextView			*textView;
}

-(IOHIDElementModel *) getIOHIDElementModelForIOHIDElementRef:(IOHIDElementRef)inIOHIDElementRef;

@property (strong) IBOutlet NSView *IOHIDDeviceView;

@property (strong) HID_Device *device;
@property (strong) IBOutlet NSCollectionView	*collectionView;
@property (strong) IBOutlet NSArrayController *arrayController;

@end

// ****************************************************
#pragma mark - external class implementations *
// ----------------------------------------------------

@implementation IOHIDDeviceWindowCtrl

- (instancetype)initWithHID_Device:(HID_Device *)aDevice
{
    self = [super initWithWindowNibName:@"IOHIDDeviceWindow"];
    if (self)
    {
        self.device = aDevice;

        [self setWindowTitle];

        // Initialization code here.
        _IOHIDElementModels = nil;
    }
    return self;
}

- (void) dealloc
{
    NSLogDebug();
    _IOHIDDeviceRef = nil;
    for (IOHIDElementModel *ioHIDElementModel in _IOHIDElementModels)
    {
        ioHIDElementModel._IOHIDElementRef = nil;
    }

    [self.arrayController setContent:NULL];
}

//- (void) windowDidLoad
//{
//    NSLogDebug();
//    [super windowDidLoad];
//
//    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
////    NSSize size = NSMakeSize(480.f, 32.f);
////    [collectionView setMinItemSize:size];
////    [collectionView setMaxItemSize:size];
//}

- (void) windowWillClose:(NSNotification *)aNotification
{
    NSLogDebug();

    // IOHIDDeviceRegisterInputValueCallback(_IOHIDDeviceRef, NULL, self);

    // [self autorelease];
}

- (void)setWindowTitle
{
    NSMutableString *title = [NSMutableString string];

    if (self.device.manufacturer)
    {
        [title appendString:self.device.manufacturer];
    }

    if (title.length == 0)
    {
        if (self.device.vendorName)
        {
            [title appendString:self.device.vendorName];
        }
    }

    if (title.length == 0)
    {
        [title appendFormat:@"vendor %ld", (long)self.device.vendorID];
    }

    NSString *product = self.device.product;

    if (product.length == 0)
    {
        product = self.device.productName;
    }

    if (product.length == 0)
    {
        product = [NSString stringWithFormat:@"- product id: %ld", (long)self.device.productID];
    }

    [title appendFormat:@" %@", product];

    self.window.title = title;
}

//
//
//
- (void) set_IOHIDDeviceRef:(IOHIDDeviceRef)inIOHIDDeviceRef
{
    NSLogDebug(@"(IOHIDDeviceRef: %p)", inIOHIDDeviceRef);
    if (_IOHIDDeviceRef != inIOHIDDeviceRef)
    {
        _IOHIDDeviceRef = inIOHIDDeviceRef;
        if (inIOHIDDeviceRef)
        {

            // iterate over all this devices elements creating model objects for each one
            NSMutableArray *tArray = [NSMutableArray array];

            NSArray *elements = (__bridge_transfer NSArray *)
            IOHIDDeviceCopyMatchingElements(inIOHIDDeviceRef,
                                            NULL,
                                            kIOHIDOptionsTypeNone);
            if (elements)
            {
                for (id element in elements)
                {
                    IOHIDElementRef tIOHIDElementRef = (__bridge IOHIDElementRef) element;

                    IOHIDElementType tIOHIDElementType = IOHIDElementGetType(tIOHIDElementRef);
                    if (tIOHIDElementType > kIOHIDElementTypeInput_ScanCodes)
                    {
                        continue;
                    }

                    uint32_t reportSize = IOHIDElementGetReportSize(tIOHIDElementRef);
                    uint32_t reportCount = IOHIDElementGetReportCount(tIOHIDElementRef);
                    if ((reportSize * reportCount) > 64)
                    {
                        continue;
                    }

                    uint32_t usagePage = IOHIDElementGetUsagePage(tIOHIDElementRef);
                    uint32_t usage = IOHIDElementGetUsage(tIOHIDElementRef);
                    if (!usagePage || !usage)
                    {
                        continue;
                    }
                    if (-1 == usage)
                    {
                        continue;
                    }
#ifdef DEBUG
                    //HIDDumpElementInfo(tIOHIDElementRef);
#endif

                    // allocate an element model
                    IOHIDElementModel *ioHIDElementModel = [[IOHIDElementModel alloc] initWithIOHIDElementRef:tIOHIDElementRef];

                    // set the element model object as a property of the IOHIDElementRef
                    // (so we can find it with getIOHIDElementModelForIOHIDElementRef)
                    IOHIDElementSetProperty(tIOHIDElementRef,
                                            CFSTR("Element Model"),
                                            (__bridge CFTypeRef) ioHIDElementModel);

                    // and add it to our array
                    [tArray addObject:ioHIDElementModel];
                }
            }

            self._IOHIDElementModels = tArray;

            // compute our frame based on the number of elements to display
            NSRect frame = [[self window] frame];
            frame.size.height = _IOHIDDeviceView.frame.size.height + (32.f * ([tArray count] + 1));
            [self.collectionView setFrame:frame];
            NSLogDebug(@"collectionView.frame: %@", NSStringFromRect(frame));

            // use screen frame to move our window to the top
            NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
            frame.origin.y = screenFrame.size.height;
            // limit window size to height of screen
            if (frame.size.height > screenFrame.size.height)
            {
                frame.origin.y = frame.size.height = screenFrame.size.height;
            }

            [[self window] setFrame:frame display:YES animate:YES];

            // use this to also set the max size
            [[self window] setMaxSize:NSMakeSize(NSWidth(frame), NSHeight(frame))];

            IOHIDDeviceRegisterInputValueCallback(inIOHIDDeviceRef,
                                                  Handle_IOHIDValueCallback,
                                                  (__bridge void *)(self));
        }
    }
}

//
// Make your array KVO compliant.
//
//
- (void) insertObject:(IOHIDElementModel *)inObj in_IOHIDElementModelsAtIndex:(NSUInteger)inIndex
{
    NSLogDebug(@"(obj: %p, index: %lu)", inObj, (unsigned long) inIndex);
    [_IOHIDElementModels insertObject:inObj atIndex:inIndex];
}

//
//
//
- (void) removeObjectFrom_IOHIDElementModelsAtIndex:(NSUInteger)inIndex
{
    NSLogDebug(@"(index: %lu)", (unsigned long) inIndex);
    [_IOHIDElementModels removeObjectAtIndex:inIndex];
}

//
//
//
- (IOHIDElementModel *) getIOHIDElementModelForIOHIDElementRef:(IOHIDElementRef)inIOHIDElementRef
{
    IOHIDElementModel *result = (__bridge IOHIDElementModel *) IOHIDElementGetProperty(inIOHIDElementRef,
                                                                                       CFSTR("Element Model"));

    return (result);
}

-(void)mouseUp:(NSEvent *)inEvent
{
#pragma unused (inEvent)
    NSLogDebug();
    for (IOHIDElementModel * elementModel in _IOHIDElementModels)
    {
        double phyVal = [elementModel phyVal];
        [elementModel setSatMin:phyVal];
        [elementModel setSatMax:phyVal];
        (void) [elementModel phyVal];
    }
}
//
//
//

@synthesize _IOHIDDeviceRef;
@synthesize _IOHIDElementModels;
// @synthesize collectionView;
// @synthesize textView;

@end
// ****************************************************
#pragma mark - local ( static ) function implementations *
// ----------------------------------------------------

//
//
//
static void Handle_IOHIDValueCallback(void *		inContext,
                                      IOReturn		inResult,
                                      void *		inSender,
                                      IOHIDValueRef inIOHIDValueRef) {
#pragma unused( inContext, inResult, inSender )
    IOHIDDeviceWindowCtrl *tIOHIDDeviceWindowCtrl = (__bridge IOHIDDeviceWindowCtrl *) inContext;
    // IOHIDDeviceRef tIOHIDDeviceRef = (IOHIDDeviceRef) inSender;

    // NSLogDebug(@"(context: %p, result: %u, sender: %p, valueRef: %p", inContext, inResult, inSender, inIOHIDValueRef);

    do
    {
        // is our device still valid?
        if (!tIOHIDDeviceWindowCtrl._IOHIDDeviceRef)
        {
            NSLogDebug(@"tIOHIDDeviceWindowCtrl._IOHIDDeviceRef == NULL");
            break;                                                              // (no)
        }

#if false
        // is this value for this device?
        if (tIOHIDDeviceRef != tIOHIDDeviceWindowCtrl._IOHIDDeviceRef) {
            NSLogDebug(@"tIOHIDDeviceRef (%p) != _IOHIDDeviceRef (%p)",
                       tIOHIDDeviceRef,
                       tIOHIDDeviceWindowCtrl._IOHIDDeviceRef);
            break;                                                              // (no)
        }

#endif                                                                          // if false
        // is this value's element valid?
        IOHIDElementRef tIOHIDElementRef = IOHIDValueGetElement(inIOHIDValueRef);
        if (!tIOHIDElementRef)
        {
            NSLogDebug(@"tIOHIDElementRef == NULL");
            break;                                                              // (no)
        }

        // length ok?
        CFIndex length = IOHIDValueGetLength(inIOHIDValueRef);
        if (length > sizeof(double_t))
        {
            break;                                                              // (no)
        }

        // find the element for this IOHIDElementRef
        IOHIDElementModel *tIOHIDElementModel = [tIOHIDDeviceWindowCtrl getIOHIDElementModelForIOHIDElementRef:tIOHIDElementRef];
        if (tIOHIDElementModel)
        {
            // update its value
            tIOHIDElementModel.phyVal = IOHIDValueGetScaledValue(inIOHIDValueRef,
                                                                 kIOHIDValueScaleTypePhysical);
        }
    } while (false);
}
