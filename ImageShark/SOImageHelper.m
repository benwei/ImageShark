//
//  SOImageHelper.m
//  ImageShark
//
//  Created by ben wei on 3/26/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//

#import "SOImageHelper.h"

@implementation SOImageHelper

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id) initWithUrl: (NSURL *) url
{
    self = [super init];
    if (self) {
        [self loadImageWithURL:url];
    }
    return self;
}

- (void) loadImageWithURL: (NSURL*)url
{
    // use ImageIO to get the CGImage, image properties, and the image-UTType
    CGImageSourceRef    isr = CGImageSourceCreateWithURL( (__bridge CFURLRef)url, NULL);
    
    if (isr)
    {
		NSDictionary *options = [NSDictionary dictionaryWithObject: (id)kCFBooleanTrue  forKey: (id) kCGImageSourceShouldCache];
        _image = CGImageSourceCreateImageAtIndex(isr, 0, (__bridge CFDictionaryRef)options);
        
        if (_image)
        {
            _properties = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(isr, 0, (__bridge CFDictionaryRef) _properties));
            
            _exif = [_properties objectForKey:(NSString *)kCGImagePropertyExifDictionary];
            _gps = [_properties objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
            
            _UTType = (__bridge NSString*)CGImageSourceGetType(isr);
        }
		CFRelease(isr);
        
    }

}

- (BOOL) WriteCGImageToFile: (CGImageRef) image path: (NSString *)path
{
    NSURL *urlPath = [NSURL fileURLWithPath:path];

    CFURLRef url = (__bridge CFURLRef) urlPath;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
        return false;
    }

    CFRelease(destination);
    return true;
}

- (NSImage *)imageResize:(NSImage*)anImage
                 newSize:(NSSize)newSize
{
    NSImage *sourceImage = anImage;
    [sourceImage setScalesWhenResized:YES];
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid])
    {
        NSLog(@"Invalid Image");
    } else
    {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

// small/medium
#define IMAGE_SIZE_SMALL 512
#define SOUI_INTERFACE_ORIENTATION_PORTRAIT  0
#define SOUI_INTERFACE_ORIENTATION_LANDSCAPE 1

- (BOOL) saveSmallThumbnail:(NSString*) resourceName
{
    return [self imageResizeToFile:resourceName withLongSize: IMAGE_SIZE_SMALL];
}

- (BOOL) imageResizeToFile: (NSString*) resourceName withLongSize: (size_t) longSize
{
    size_t height = CGImageGetHeight(self.image);
    size_t width = CGImageGetWidth(self.image);
    NSSize size = NSMakeSize(width, height);
    int orientation = SOUI_INTERFACE_ORIENTATION_PORTRAIT;
    self.imageSize = size;

    if (longSize == 0) {
        longSize = IMAGE_SIZE_SMALL;
    }

    if (height > width) {
        longSize = height;
    } else {
        longSize = width;
        orientation = SOUI_INTERFACE_ORIENTATION_LANDSCAPE;
    }

    // don't need to resize, it is small one.
    if (longSize < IMAGE_SIZE_SMALL) {
        self.thumbnailName = [NSString stringWithFormat:@"%@.jpg", resourceName];
    } else {
        if (orientation == SOUI_INTERFACE_ORIENTATION_PORTRAIT) {
            size.height = IMAGE_SIZE_SMALL;
            size.width  = (size.height * width) / height;
        } else {
            size.width  = IMAGE_SIZE_SMALL;
            size.height  = (size.width * height) / width;
        }

        self.thumbnailName = [NSString stringWithFormat:@"%@_%.0fx%.0f.jpg", resourceName, size.width, size.height];
    }
    self.thumbnailSize = size;
    return [self saveJPGFileWithSize:self.thumbnailName withSize:size];
}

- (BOOL) saveJPGFileWithSize: (NSString *) pathName withSize: (NSSize) size;
{
    NSImage *handle = [[NSImage alloc] initWithCGImage:self.image size:size];
    if (!handle)
    {
        return false;
    }

    NSArray *reps = [handle representations];

    [handle lockFocusOnRepresentation:[reps objectAtIndex:0]];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, size.width, size.height)];
    [handle unlockFocus];
    
    NSData *data = [rep representationUsingType:NSJPEGFileType properties:self.properties];
    
    [data writeToFile:pathName atomically:NO];
    
    return true;
}

@end
