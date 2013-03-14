//
//  KARDView.m
//  KARD
//
//  Created by Tyler on 2013-03-13.
//  Copyright (c) 2013 ICAD. All rights reserved.
//
#pragma mark - Defines -
#define kBatteryMaxValue        100
#define kBatteryCriticalValue   15
#define kBatteryWarningValue    30

#import "KARDView.h"

@implementation KARDView

@synthesize pilot, pilotView, wiimote;
@synthesize wiiPitchText, wiiRollText;
@synthesize wiiX, wiiY, wiiZ;
@synthesize wiimoteOrientationButton;
@synthesize batteryLevelIndicator, wiimoteConnectionButton;
@synthesize ardroneFlyingStatus;

BOOL isDroneAscending               = FALSE;
BOOL isWiiButtonPressed             = FALSE;
BOOL isDroneTurningRight            = FALSE;
BOOL isWiimoteConnected             = FALSE;
BOOL isWiimoteOrientationVertical   = FALSE;
BOOL isKinectTracking               = FALSE;

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
    
    wiimote = [Wiimote new];
    [wiimote setDelegate:self];
    
    
    [batteryLevelIndicator setMaxValue:kBatteryMaxValue];
    [batteryLevelIndicator setCriticalValue:kBatteryCriticalValue];
    [batteryLevelIndicator setWarningValue:kBatteryWarningValue];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryStarted:) name:WiimoteBeginDiscoveryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryEnded:) name:WiimoteEndDiscoveryNotification object:nil];
    
    [[WiimoteWatchdog sharedWatchdog] setEnabled:YES];
    [self resetWiimoteStatus];
}

- (IBAction)toggleWiimoteConnection:(id)sender {
    if(isWiimoteConnected) {
        NSLog(@"Disconnecting\n");
        [self resetWiimoteStatus];
        [wiimote disconnect];
        isWiimoteConnected = FALSE;
    } else {
        [Wiimote beginDiscovery];
        [[self wiimoteConnectionButton] setTitle: @"Connecting..."];
    }
}


- (IBAction)toggleWiimoteOrientation:(id)sender
{
    if(isWiimoteOrientationVertical) {
        [wiimoteOrientationButton setFrameCenterRotation:90];
        [wiimote setHighlightedLEDMask:2];
    } else {
        [wiimoteOrientationButton setFrameCenterRotation:0];
        [wiimote setHighlightedLEDMask:1];
    }
    
    isWiimoteOrientationVertical = !isWiimoteOrientationVertical;
}

- (IBAction)toggleKinectTracking:(id)sender
{
    isKinectTracking = !isKinectTracking;
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
        
        isWiimoteOrientationVertical ? [wiimote setHighlightedLEDMask:1] : [wiimote setHighlightedLEDMask:2];
        
        [[wiimote accelerometer] setEnabled:YES];
        
        [[self wiimoteConnectionButton] setTitle:@"Disconnect"];
        
        isWiimoteConnected = TRUE;
        
        [wiimote playConnectEffect];
        
    } else {
        NSLog(@"Cannot connect find a Wiimote\n");
        isWiimoteConnected = FALSE;
    }
}

#pragma mark - Wiimote Delegates -
- (void)resetWiimoteStatus
{
    [wiimoteConnectionButton setTitle:@"Connect"];
    
    [batteryLevelIndicator setDoubleValue:0.0];
    [wiiZ setStringValue:@""];
    [wiiX setStringValue:@""];
    [wiiY setStringValue:@""];
    [wiiRollText setStringValue:@""];
    [wiiPitchText setStringValue:@""];
}

- (void)wiimote:(Wiimote*)wiimote
  buttonPressed:(WiimoteButtonType)button
{
    switch(button) {
        case WiimoteButtonTypeMinus:
            [self resetWiimoteStatus];
            [[self wiimote] disconnect];
            isWiimoteConnected = FALSE;
            break;
        case WiimoteButtonTypeOne:
            isWiimoteOrientationVertical = TRUE;
            [wiimoteOrientationButton setFrameCenterRotation:0];
            [[self wiimote] setHighlightedLEDMask:1];
            break;
        case WiimoteButtonTypeTwo:
            isWiimoteOrientationVertical = FALSE;
            [wiimoteOrientationButton setFrameCenterRotation:90];
            [[self wiimote] setHighlightedLEDMask:2];
            break;
        case WiimoteButtonTypeA:
            [pilot takeOff];
            [ardroneFlyingStatus setStringValue: @"Taking Off"];
            break;
        case WiimoteButtonTypeB:
            [pilot land];
            [ardroneFlyingStatus setStringValue: @"Landing Down"];
            break;
        case WiimoteButtonTypeHome:
            [ardroneFlyingStatus setStringValue: @"Emergency"];
            [pilot emergency];
            break;
        case WiimoteButtonTypeDown:
            isWiiButtonPressed = TRUE;
            if(isWiimoteOrientationVertical) isDroneAscending = FALSE;
            else isDroneTurningRight = TRUE;
            break;
        case WiimoteButtonTypeUp:
            isWiiButtonPressed = TRUE;
            if(isWiimoteOrientationVertical) isDroneAscending = TRUE;
            else isDroneTurningRight = FALSE;
            break;
        case WiimoteButtonTypeRight:
            isWiiButtonPressed = TRUE;
            if(isWiimoteOrientationVertical) isDroneAscending = TRUE;
            else isDroneTurningRight = TRUE;
            break;
        case WiimoteButtonTypeLeft:
            isWiiButtonPressed = TRUE;
            if(isWiimoteOrientationVertical) isDroneAscending = FALSE;
            else isDroneTurningRight = FALSE;
            break;
        default: break;
    }
    
    // Note: the 'isWiiButtonPressed = TRUE' states are momentary so we allow it to only enable during each transmission
    isWiiButtonPressed = FALSE;
}
/*
- (void)wiimote:(Wiimote*)wiimote
 buttonReleased:(WiimoteButtonType)button
{
    isWiiButtonPressed = FALSE;
}
 */

- (void)wiimote:(Wiimote*)wiimote batteryLevelUpdated:(double)batteryLevel isLow:(BOOL)isLow {
    NSLog(@"Battery: %f\n", batteryLevel);
}

- (void)wiimote:(Wiimote*)wiimote
accelerometerChangedGravityX:(double)x
              y:(double)y
              z:(double)z {
    
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
    float gaz = 0.0f;
    
    if (!isWiimoteOrientationVertical) {
        theta = -roll / 90.0f;
        phi = -pitch / 90.0f;
        
        if(theta > 1.0f) theta = 1.0f;
        else if(theta < -1.0f) theta = -1.0f;
        
        if(phi > 1.0f) phi = 1.0f;
        else if(phi < -1.0f) phi = -1.0f;
    } else {
        
        theta = -pitch / 90.0f;
        phi = roll / 90.0f;
        
        if(theta > 1.0f) theta = 1.0f;
        else if(theta < -1.0f) theta = -1.0f;
        
        if(phi > 1.0f) phi = 1.0f;
        else if(phi < -1.0f) phi = -1.0f;
    }
    
    if(isWiiButtonPressed) {
        if(isDroneAscending) { gaz = 0.5;
            NSLog(@"UP\n");}
        else {
            NSLog(@"DOWN\n");
            gaz = -0.5; } 
    } else {
        NSLog(@"Not pressed\n");
    }
    
    [pilot moveTheta: theta phi: phi gaz: gaz];
    
    // set the battery state
    // TODO: This needs to be moved into a responder where we can independently set the batteryLevel
    // PRIORITY: Very low due to possible performance hit (minor) for waiting on a separate message, and battery level just isn't that valuable for the wiimote
    [[self batteryLevelIndicator] setDoubleValue:[[self wiimote] batteryLevel]];
}

@end
