//
//  AppDelegate.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KPilot.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (readonly, strong, nonatomic) KPilot * pilot;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
