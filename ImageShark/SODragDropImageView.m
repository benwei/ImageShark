//
//  File: SODragDropImageView.m
//  ImageShark
//
//  Created by ben wei on 3/28/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//  License: Simple BSD https://github.com/benwei/ImageShark/blob/master/License.txt

#import "SODragDropImageView.h"
#import "AppDelegate.h"

@implementation SODragDropImageView {
    BOOL highlightWithFrame;
}

#define SO_LINE_WITH_FOR_HIGHLIGHT_FRAME 3

- (id) initWithCoder: (NSCoder *)coder
{
    self=[super initWithCoder:coder];
    if ( self ) {
        [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
        _lineWidthForHighlightFrame = [NSNumber numberWithInteger:SO_LINE_WITH_FOR_HIGHLIGHT_FRAME];
    }
    return self;
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] & NSDragOperationCopy ) {
        [self displayHightlightFrame: YES];
        // accept image file drag entered
        return NSDragOperationCopy;
    }

    return NSDragOperationNone;
}


- (void) displayHightlightFrame: (BOOL) enabled {
    highlightWithFrame=enabled;
    [self setNeedsDisplay: YES];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [self displayHightlightFrame: NO];
    NSLog(@"draggingExited");
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    [self displayHightlightFrame: NO];
    NSLog(@"prepareForDragOperation");
    return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ( [sender draggingSource] != self ) {
        NSURL* fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
        NSLog(@"fileUrl: %@", fileURL);
        
        // The follow method to get delete is fit to this app's use-case.
        AppDelegate *main = [[NSApplication sharedApplication] delegate];
        [main openImageURL:fileURL];
    }
    
    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;
{
    NSRect ContentRect=self.window.frame;
    ContentRect.size=[[self image] size];
    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
};

-(void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if ( highlightWithFrame ) {
        [[NSColor redColor] set];
        [NSBezierPath setDefaultLineWidth: [_lineWidthForHighlightFrame intValue]];
        [NSBezierPath strokeRect: rect];
    }
}

@end
