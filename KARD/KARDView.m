//
//  KARDView.m
//  KARD
//
//  Created by Tyler on 2013-03-13.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#define kBatteryMaxValue        100
#define kBatteryCriticalValue   15
#define kBatteryWarningValue    30

#import "KARDView.h"

@implementation KARDView

@synthesize pilot, pilotView, wiimote;

@synthesize isKinectTracking, isWiiConnected, isWiiVertical;
@synthesize wiiPitchText, wiiRollText;
@synthesize wiiX, wiiY, wiiZ;
@synthesize wiimoteOrientationButton;

- (void)updateBatteryStatus:(NSString *)batteryStatus {
    NSLog(@"battery status: %@\n", batteryStatus);
    [[pilotView batteryLevel] setStringValue:batteryStatus];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}


- (void) awakeFromNib {
    pilot = [KPilot new];
    [pilot initPilot];
    
    isKinectTracking = FALSE;
    isWiiConnected = FALSE;
    isWiiVertical = TRUE;
    
    pilotView = [KPilotView new];
    [pilotView initPilotView];
    //[pilotView setDelegate:self];
    [[pilotView delegate] updateBatteryStatus:@"Test"];
    
    wiimote = [Wiimote new];
    [wiimote setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryStarted:) name:WiimoteBeginDiscoveryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryEnded:) name:WiimoteEndDiscoveryNotification object:nil];
    
    [[WiimoteWatchdog sharedWatchdog] setEnabled:YES];
    
    [[self batteryLevelIndicator] setMaxValue:kBatteryMaxValue];
    [[self batteryLevelIndicator] setCriticalValue:kBatteryCriticalValue];
    [[self batteryLevelIndicator] setWarningValue:kBatteryWarningValue];
    
    [[self wiimoteConnectionButton] setTitle:@"Connect"];
    NSLog(@"AwakeFromNib\n");
    
    [[self batteryLevelIndicator] setDoubleValue:0.0];
    [wiiZ setStringValue:@""];
    [wiiX setStringValue:@""];
    [wiiY setStringValue:@""];
    [wiiRollText setStringValue:@""];
    [wiiPitchText setStringValue:@""];
}

- (IBAction)toggleWiimoteConnection:(id)sender {
    if(isWiiConnected) {
        NSLog(@"Disconnecting\n");
        [wiimote disconnect];
        [[self wiimoteConnectionButton] setTitle: @"Connect"];
        isWiiConnected = FALSE;
    } else {
        [Wiimote beginDiscovery];
        [[self wiimoteConnectionButton] setTitle: @"Connecting..."];
    }
}


- (IBAction)toggleWiimoteOrientation:(id)sender
{
    if(isWiiVertical) {
        [wiimoteOrientationButton setFrameCenterRotation:90];
    } else {
        [wiimoteOrientationButton setFrameCenterRotation:0];
    }
    
    isWiiVertical = !isWiiVertical;
}

- (IBAction)toggleKinectTracking:(id)sender {
}



- (void) wiimoteDiscoveryStarted: (NSNotification *)notification {
    NSLog(@"Wiimote Discovery Started\n");
    [[self wiimoteConnectionButton] setEnabled:FALSE];
}

- (void) wiimoteDiscoveryEnded: (NSNotification *)notification {
    int connectedDevices = (int)[[Wiimote connectedDevices] count];
    
    [[self wiimoteConnectionButton] setEnabled:TRUE];
    
    NSLog(@"Wiimote Discovery Ended\n");
    NSLog(@"Number of connected devices: %i\n", connectedDevices);
    
    if(connectedDevices > 0) {
        wiimote = [[Wiimote connectedDevices] objectAtIndex:0];
        [wiimote setDelegate:self];
        [wiimote setHighlightedLEDMask:1];
        [[wiimote accelerometer] setEnabled:YES];
        
        [[self wiimoteConnectionButton] setTitle:@"Disconnect"];
        
        isWiiConnected = TRUE;
        
        [wiimote playConnectEffect];
    } else {
        NSLog(@"Cannot connect find a Wiimote\n");
        isWiiConnected = FALSE;
    }
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
- (void)wiimote:(Wiimote*)wiimote batteryLevelUpdated:(double)batteryLevel isLow:(BOOL)isLow {
    NSLog(@"Battery: %f\n", batteryLevel);
}
//- (void)wiimote:(Wiimote*)wiimote irEnabledStateChanged:(BOOL)enabled;
//- (void)wiimote:(Wiimote*)wiimote irPointPositionChanged:(WiimoteIRPoint*)point;
//- (void)wiimote:(Wiimote*)wiimote accelerometerEnabledStateChanged:(BOOL)enabled;

- (void)wiimote:(Wiimote*)wiimote
accelerometerChangedGravityX:(double)x
              y:(double)y
              z:(double)z {
    //NSLog(@"\nx: %f\ny: %f\nz: %f\n", x, y, z);
    //NSLog(@"-------------\n");
    
    [wiiX setDoubleValue:x];
    [wiiY setDoubleValue:y];
    [wiiZ setDoubleValue:z];
}

- (void)wiimote:(Wiimote*)wiimote
accelerometerChangedPitch:(double)pitch
           roll:(double)roll
{
    [wiiRollText setDoubleValue:roll];
    [wiiPitchText setDoubleValue:pitch];
    
    float theta;
    float phi;
    
    if (isWiiVertical) {
        theta = -roll / 90.0f;
        phi = -pitch / 90.0f;
        
        if(theta > 1.0f) theta = 1.0f;
        else if(theta < -1.0f) theta = -1.0f;
        
        if(phi > 1.0f) phi = 1.0f;
        else if(phi < -1.0f) phi = -1.0f;
    } else {
        theta = -pitch / 90.0f;
        phi = -roll / 90.0f;
        
        if(theta > 1.0f) theta = 1.0f;
        else if(theta < -1.0f) theta = -1.0f;
        
        if(phi > 1.0f) phi = 1.0f;
        else if(phi < -1.0f) phi = -1.0f;
    }
    
    
    //NSLog(@"Theta: %f\n", theta);
    [pilot moveTheta: theta phi: phi];
    
    // set the battery state
    [[self batteryLevelIndicator] setDoubleValue:[wiimote batteryLevel]];
}

@end
