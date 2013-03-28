//
//  File: SODragDropImageView.h
//  ImageShark
//
//  Created by ben wei on 3/28/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//  License: Simple BSD https://github.com/benwei/ImageShark/blob/master/License.txt

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface SODragDropImageView : NSImageView <NSDraggingDestination>
{
    BOOL highlightWithFrame;
}

- (id) initWithCoder: (NSCoder *) coder;

@end
