//
//  AppDelegate.m
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize pilot, pilotView;//, wiimote, wiimoteDiscovery;

- (void)updateBatteryStatus:(NSString *)batteryStatus {
    NSLog(@"battery status: %@\n", batteryStatus);
    [[pilotView batteryLevel] setStringValue:batteryStatus];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    pilot = [KPilot new];
    [pilot initPilot];
    
    pilotView = [KPilotView new];
    [pilotView initPilotView];
    [pilotView setDelegate:self];
    [[pilotView delegate] updateBatteryStatus:@"Test"];
    
    wiimote = [Wiimote new];
    [wiimote setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryStarted:) name:WiimoteBeginDiscoveryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryEnded:) name:WiimoteEndDiscoveryNotification object:nil];
    
    [[WiimoteWatchdog sharedWatchdog] setEnabled:YES];
    [Wiimote beginDiscovery];
}

- (void) wiimoteDiscoveryStarted: (NSNotification *)notification {
    NSLog(@"Wiimote Discovery Started\n");
}

- (void) wiimoteDiscoveryEnded: (NSNotification *)notification {
    NSLog(@"Wiimote Discovery Ended\n");
    NSLog(@"Number of connected devices: %i\n", (int)[[Wiimote connectedDevices] count]);
    
    wiimote = [[Wiimote connectedDevices] objectAtIndex:0];
    [wiimote setDelegate:self];
    [wiimote setHighlightedLEDMask:1];
    [[wiimote accelerometer] setEnabled:YES];
    NSLog(@"Battery Level: %f\n", [wiimote batteryLevel]);
}

#pragma Wiimote Delegates
- (void)wiimote:(Wiimote*)wiimote
  buttonPressed:(WiimoteButtonType)button
{
    switch(button) {
        case WiimoteButtonTypeA:
            NSLog(@"Take Off\n");
            [pilot takeOff];
            break;
        case WiimoteButtonTypeB:
            NSLog(@"Land\n");
            [pilot land];
            break;
        case WiimoteButtonTypeHome:
            ardrone_tool_set_ui_pad_select(1);
            break;
        default: break;
    }
}

/*- (void)wiimote:(Wiimote*)wiimote
 buttonReleased:(WiimoteButtonType)button
{
    switch(button) {
        case WiimoteButtonTypeHome:
            ardrone_tool_set_ui_pad_select(1);
            break;
        default: break;
    }
}*/

//- (void)wiimote:(Wiimote*)wiimote vibrationStateChanged:(BOOL)isVibrationEnabled;
//- (void)wiimote:(Wiimote*)wiimote highlightedLEDMaskChanged:(NSUInteger)mask;
//- (void)wiimote:(Wiimote*)wiimote batteryLevelUpdated:(double)batteryLevel isLow:(BOOL)isLow;
//- (void)wiimote:(Wiimote*)wiimote irEnabledStateChanged:(BOOL)enabled;
//- (void)wiimote:(Wiimote*)wiimote irPointPositionChanged:(WiimoteIRPoint*)point;
//- (void)wiimote:(Wiimote*)wiimote accelerometerEnabledStateChanged:(BOOL)enabled;

- (void)wiimote:(Wiimote*)wiimote
    accelerometerChangedGravityX:(double)x
              y:(double)y
              z:(double)z {
    NSLog(@"\nx: %f\ny: %f\nz: %f\n", x, y, z);
    NSLog(@"-------------\n");
    
}

- (void)wiimote:(Wiimote*)wiimote
    accelerometerChangedPitch:(double)pitch
           roll:(double)roll
{
    float theta = -roll / 90.0f;
    float phi = -pitch / 90.0f;
    
    if(theta > 1.0f) theta = 1.0f;
    else if(theta < -1.0f) theta = -1.0f;
    
    if(phi > 1.0f) phi = 1.0f;
    else if(phi < -1.0f) phi = -1.0f;
    
    
    NSLog(@"Theta: %f\n", theta);
    [pilot moveTheta: theta phi: phi];
}

//- (void)wiimote:(Wiimote*)wiimote extensionConnected:(WiimoteExtension*)extension;
//- (void)wiimote:(Wiimote*)wiimote extensionDisconnected:(WiimoteExtension*)extension;
//- (void)wiimoteDisconnected:(Wiimote*)wiimote;

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "ICAD.KARD" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"ICAD.KARD"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"KARD" withExtension:@"momd"];
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
        /*
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }*/
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"KARD.storedata"];
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

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
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

@end
