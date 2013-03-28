//
//  SOImageHelper.m
//  ImageShark
//
//  Created by ben wei on 3/26/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//  License: Simple BSD https://github.com/benwei/ImageShark/blob/master/License.txt

#import "SOImageHelper.h"

@implementation SOImageHelper {
    CGImageSourceRef    isr;
}

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
    isr = CGImageSourceCreateWithURL( (__bridge CFURLRef)url, NULL);
    
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

// small/medium
#define IMAGE_SIZE_SMALL 512
#define IMAGE_SIZE_MEDIUM 1024

#define SOUI_INTERFACE_ORIENTATION_PORTRAIT  0
#define SOUI_INTERFACE_ORIENTATION_LANDSCAPE 1

- (BOOL) saveSmallThumbnail:(NSString*) resourceName
{
    return [self imageResizeToFile:resourceName withLongSize: IMAGE_SIZE_SMALL];
}

- (BOOL) saveMediumThumbnail:(NSString*) resourceName
{
    return [self imageResizeToFile:resourceName withLongSize: IMAGE_SIZE_MEDIUM];
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
        self.thumbnailSize = size;
        return [self saveJPGFileWithSize:self.image withPath: self.thumbnailName withSize:size];
    } else {
        // handle the correct rotation of thumbnail
        CGImageRef imageThumbnail = CGImageSourceCreateThumbnailAtIndex(isr, 0,
                                        (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [NSNumber numberWithInt: IMAGE_SIZE_SMALL],  kCGImageSourceThumbnailMaxPixelSize,
                                                                   (id)kCFBooleanTrue,                       kCGImageSourceCreateThumbnailWithTransform,
                                                                   (id)kCFBooleanTrue,                       kCGImageSourceCreateThumbnailFromImageAlways,
                                                                   NULL]);

        height = CGImageGetHeight(imageThumbnail);
        width = CGImageGetWidth(imageThumbnail);
        size = NSMakeSize(width, height);
        self.thumbnailName = [NSString stringWithFormat:@"%@_%.0fx%.0f.jpg", resourceName, size.width, size.height];
        return [self saveJPGFileWithSize:imageThumbnail withPath: self.thumbnailName withSize:size];
    }
}

- (BOOL) saveJPGFileWithSize: (CGImageRef) imageSrc withPath: (NSString *) pathName withSize: (NSSize) size;
{

    BOOL retflg = NO;
    NSImage *dest = [[NSImage alloc] initWithCGImage:imageSrc size:size];
    if (!dest) {
        return retflg;
    }

    [dest lockFocus];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[dest TIFFRepresentation]];
    NSData *data = [rep representationUsingType:NSJPEGFileType properties: _properties];
    retflg = [data writeToFile:pathName atomically:NO];
    [dest unlockFocus];
    
    return retflg;
}

@end
