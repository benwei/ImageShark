//
//  AppDelegate.m
//  ImageShark
//
//  Created by ben wei on 3/14/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//

#import "SOImageHelper.h"
#import "AppDelegate.h"

@implementation AppDelegate {
    SOImageHelper *helper;
    NSURL *fileUrl;
    NSString *targetExportPath;
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    helper = nil;
    targetExportPath = [NSString stringWithFormat:@"%@/Desktop", NSHomeDirectory()];
    [_exportPath setStringValue:targetExportPath];
    _dispMessages = @"open your photo first to display EXIF and GPS info\r\
* load new image by [File]->[Open]\r\
 - select your file. if image loads successfully and exif or gps exists,\r\
   info will be right-side text field.\r\
* export thumbnail by [File]->[Export]\r\
 - if works, output info in text field and thumbnail in\r\
   ~/Desktop/<filename>_<width>x<height>.jpg";

    [_detail setStringValue:_dispMessages];
}

// Returns the directory the application uses to store the Core Data store file.
// This code uses a directory named "mobi.staros.apps.ImageShark" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"mobi.staros.apps.ImageShark"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ImageShark" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"ImageShark.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

#pragma mark -------- file opening


- (IBAction)openImage: (id)sender
{
    // present open panel...
    
    NSString *    extensions = @"tiff/tif/TIFF/TIF/jpg/jpeg/JPG/JPEG/png/PNG";
    NSArray *     types = [extensions pathComponents];
    
	// Let the user choose an output file, then start the process of writing samples
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:types/*[NSArray arrayWithObject:AVFileTypeQuickTimeMovie]*/];
	[openPanel setCanSelectHiddenExtension:YES];
	[openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton)
        {
            // user did select an image...
            fileUrl = [openPanel URL];
            [self openImageURL: fileUrl];
        }
	}];
}

- (void)openImageURL: (NSURL*)url
{
    fileUrl = url;
    helper = [[SOImageHelper alloc] initWithUrl:url];
    
    if (helper.image)
    {
        [_imageView setImage: helper.image
             imageProperties: helper.properties];
        [_detail setStringValue:[NSString stringWithFormat:@"exif=%@\rGPS=%@", helper.exif, helper.gps]];
        
        [_window setTitleWithRepresentedFilename: [url path]];
    }
}

- (IBAction)exportTo:(id)sender
{
    if (!helper) {
        [_detail setStringValue:@"Please open your image at first."];
        return;
    }

    NSString *fileName = [[fileUrl path] lastPathComponent];
    NSString *fileNameOnly = [[fileName lastPathComponent] stringByDeletingPathExtension];
    NSString *exportResName = [NSString stringWithFormat:@"%@/%@", targetExportPath, fileNameOnly];
    NSString *msg = nil;
    
    if ([helper saveSmallThumbnail:exportResName]) {
        msg = [NSString stringWithFormat:@"Source:%@\r\routput:%@\r\rOrigin Size: (%.0f,%.0f)\r\rThumbnail Size: (%.0f,%.0f)",
         fileUrl, helper.thumbnailName,
         helper.imageSize.width,
         helper.imageSize.height,
         helper.thumbnailSize.width,
         helper.thumbnailSize.height];
    } else {
        msg = [NSString stringWithFormat:@"Error: export %@ To %@", fileUrl, helper.thumbnailName];
    }

    if (msg) {
        [_detail setStringValue:msg];
    }
}

- (IBAction) browseExportFolder:(id)sender
{
    NSURL *url = [NSURL fileURLWithPath:targetExportPath];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
