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

@interface KARDView : NSView

@property (nonatomic, retain) IBOutlet NSButton * wiimoteConnectionButton;
@property (nonatomic, retain) IBOutlet NSButton * kinectTrackingButton;
@property (nonatomic, retain) IBOutlet NSButton * wiimoteOrientationButton;

@property (nonatomic, retain) IBOutlet NSLevelIndicator * batteryLevelIndicator;

@property (readonly, strong, nonatomic) KPilot * pilot;
@property (readonly, strong, nonatomic) KPilotView * pilotView;
@property (readonly, retain, nonatomic) Wiimote * wiimote;

@property (nonatomic, retain) IBOutlet NSTextField * wiiRollText;
@property (nonatomic, retain) IBOutlet NSTextField * wiiPitchText;
@property (nonatomic, retain) IBOutlet NSTextField * wiiX;
@property (nonatomic, retain) IBOutlet NSTextField * wiiY;
@property (nonatomic, retain) IBOutlet NSTextField * wiiZ;

@property (nonatomic) BOOL isWiiConnected;
@property (nonatomic) BOOL isKinectTracking;
@property (nonatomic) BOOL isWiiVertical;

- (IBAction)toggleWiimoteConnection:(id)sender;
- (IBAction)toggleKinectTracking:(id)sender;
- (IBAction)toggleWiimoteOrientation:(id)sender;

@end
