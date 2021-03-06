//
//  SOImageHelper.h
//  ImageShark
//
//  Created by ben wei on 3/26/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//  License: Simple BSD https://github.com/benwei/ImageShark/blob/master/License.txt


#import <Foundation/Foundation.h>

@interface SOImageHelper : NSObject {
}

@property (strong, nonatomic) NSDictionary* properties;
@property (strong, nonatomic) NSDictionary* exif;
@property (strong, nonatomic) NSDictionary* gps;
@property (strong, nonatomic) NSString*     UTType;
@property (nonatomic) CGImageRef image;
@property (nonatomic) NSSize                imageSize;
@property (nonatomic) NSSize                thumbnailSize;
@property (strong, nonatomic) NSString*     thumbnailName;

- (id) initWithUrl: (NSURL *) url;

- (BOOL) WriteCGImageToFile: (CGImageRef) image path: (NSString *)path;

- (BOOL) imageResizeToFile: (NSString*) resourceName  withLongSize: (size_t) longSize;

// Thumbnail Creation
- (BOOL) saveSmallThumbnail:(NSString*) resourceName;
- (BOOL) saveMediumThumbnail:(NSString*) resourceName;

@end
