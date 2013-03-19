//
//  KARDView.h
//  KARD
//
//  Created by Tyler on 2013-03-13.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Wiimote/Wiimote.h>
#import "KPilot.h"
#import "KPilotView.h"
#import "KVisionOpenGLView.h"

@interface KARDView : NSView <NSTabViewDelegate>

@property (nonatomic, retain) IBOutlet NSButton * wiimoteConnectionButton;
@property (nonatomic, retain) IBOutlet NSButton * kinectTrackingButton;
@property (nonatomic, retain) IBOutlet NSButton * wiimoteOrientationButton;
@property (nonatomic, retain) IBOutlet NSTextField * ardroneFlyingStatus;
@property (nonatomic, retain) IBOutlet NSTextField * ardroneBatteryStatus;

@property (nonatomic, retain) IBOutlet NSLevelIndicator * wiimoteBatteryLevelIndicator;
@property (nonatomic, retain) IBOutlet NSLevelIndicator * droneBatteryLevelIndicator;

@property (nonatomic, retain) KPilot * pilot;
@property (nonatomic, retain) KPilotView * pilotView;
@property (nonatomic, retain) Wiimote * wiimote;
@property (nonatomic, retain) IBOutlet KVisionOpenGLView * kinectView;
@property (nonatomic, retain) IBOutlet NSTabView * tabView;

// Wiimote
@property (nonatomic, retain) IBOutlet NSTextField * wiiRollText;
@property (nonatomic, retain) IBOutlet NSTextField * wiiPitchText;
@property (nonatomic, retain) IBOutlet NSTextField * wiiX;
@property (nonatomic, retain) IBOutlet NSTextField * wiiY;
@property (nonatomic, retain) IBOutlet NSTextField * wiiZ;

// Drone
@property (nonatomic, retain) IBOutlet NSTextField * ardroneTheta;
@property (nonatomic, retain) IBOutlet NSTextField * ardronePhi;
@property (nonatomic, retain) IBOutlet NSTextField * ardronePsi;
@property (nonatomic, retain) IBOutlet NSTextField * ardroneAltitude;

- (IBAction)toggleWiimoteConnection:(id)sender;
- (IBAction)toggleKinectTracking:(id)sender;
- (IBAction)toggleWiimoteOrientation:(id)sender;

@end
