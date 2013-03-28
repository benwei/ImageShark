//
//  AppDelegate.h
//  ImageShark
//
//  Created by ben wei on 3/14/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class IKImageView;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet IKImageView *  _imageView;
    IBOutlet NSTextField *  _detail;
    NSDictionary*           _imageProperties;
    NSString*               _imageUTType;
    NSDictionary*           _exif;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic)           NSString *dispMessages;

- (IBAction)saveAction:(id)sender;

@end
