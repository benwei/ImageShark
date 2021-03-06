//
//  AppDelegate.m
//  ImageShark
//
//  Created by ben wei on 3/14/13.
//  Copyright (c) 2013 Staros Mobi. All rights reserved.
//

#import "SOImageHelper.h"
#import "AppDelegate.h"

#pragma mark -------- AppDelegate

@implementation AppDelegate {
    SOImageHelper *helper;
    NSURL *fileUrl;
    NSString *targetExportPath;
    NSUserDefaults *defaults;
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    defaults = [NSUserDefaults standardUserDefaults];

    helper = nil;
    targetExportPath = [defaults objectForKey:@"exportFolder"];
    if (!targetExportPath || [targetExportPath length] == 0) {
        targetExportPath = [NSString stringWithFormat:@"%@/Desktop", NSHomeDirectory()];
    }

    [_exportPath setStringValue:targetExportPath];
    _dispMessages = NSLocalizedString(@"Introduction", @"");

    [_detail setStringValue:_dispMessages];
}

- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"mobi.staros.apps.ImageShark"];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ImageShark" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

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

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
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
    NSString *    extensions = @"tiff/tif/TIFF/TIF/jpg/jpeg/JPG/JPEG/png/PNG";
    NSArray *     types = [extensions pathComponents];
    
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowedFileTypes:types];
	[openPanel setCanSelectHiddenExtension:YES];
	[openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton)
        {
            fileUrl = [openPanel URL];
            [self openImageURL: fileUrl];
        }
	}];
}


- (IBAction) selectExportFolder: (id)sender
{
    
    NSOpenPanel *savePanel = [NSOpenPanel openPanel];
    [savePanel setDirectoryURL:fileUrl];
    [savePanel setCanChooseDirectories: YES];
    [savePanel setCanCreateDirectories: YES];
    [savePanel setCanChooseFiles: NO];
    [savePanel setPrompt:@"Save"];
    
	[savePanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton)
        {
            fileUrl = [savePanel URL];
            targetExportPath = [fileUrl path];
            NSLog(@"selected Export Folder: %@", targetExportPath);
            [defaults setObject:targetExportPath forKey:@"exportFolder"];
            [_exportPath setStringValue:targetExportPath];
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
