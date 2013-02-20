//
//  AppDelegate.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "KPilot.h"
#include <XnOpenNI.h>

PROTO_THREAD_ROUTINE(opengl, data);

/**
 * Declare Threads / Navdata tables
 */
BEGIN_THREAD_TABLE
THREAD_TABLE_ENTRY( opengl, 20 )
THREAD_TABLE_ENTRY( ardrone_control, 20 )
THREAD_TABLE_ENTRY( navdata_update, 20 )
THREAD_TABLE_ENTRY( video_stage, 20 )
THREAD_TABLE_ENTRY( video_recorder, 20)
END_THREAD_TABLE

BEGIN_NAVDATA_HANDLER_TABLE
    NAVDATA_HANDLER_TABLE_ENTRY(navdata_client_init, navdata_client_process, navdata_client_release, NULL)
END_NAVDATA_HANDLER_TABLE


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
