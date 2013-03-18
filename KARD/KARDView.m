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
#define kAngleThreshold         90.0f

#import "KARDView.h"

@implementation KARDView

@synthesize pilot, pilotView, wiimote;
@synthesize wiiPitchText, wiiRollText;
@synthesize wiiX, wiiY, wiiZ;
@synthesize wiimoteOrientationButton;
@synthesize wiimoteBatteryLevelIndicator, droneBatteryLevelIndicator, wiimoteConnectionButton;
@synthesize ardroneFlyingStatus, ardroneBatteryStatus;
@synthesize ardronePhi, ardroneTheta, ardronePsi, ardroneAltitude;

// indicators for the status of the drone
NSNumber * isDroneAscending;
NSNumber * isDroneTurningRight;

// TODO: fix this requirement
// using for nullable states
NSNumber * isTrue;
NSNumber * isFalse;

BOOL isWiimoteOrientationVertical   = TRUE;
BOOL isWiimoteConnected             = FALSE;
BOOL isKinectTracking               = FALSE;
BOOL isWiiButtonPressed             = FALSE;

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
    [self update];
}

- (void)idle:(NSTimer*)timer
{
    [self setNeedsDisplay:YES];
}

- (void) update
{
    // set batteryStatus
    [droneBatteryLevelIndicator setDoubleValue:[pilot batteryLevel]];
    [ardroneBatteryStatus setStringValue:[NSString stringWithFormat:@"%0.f%%", [pilot batteryLevel]]];
    
    // set coords
    [ardronePhi setFloatValue:[pilot phi]];
    [ardronePsi setFloatValue:[pilot psi]];
    [ardroneTheta setFloatValue:[pilot theta]];
    [ardroneAltitude setFloatValue:[pilot altitude]];
    
    NSLog(@"phi: %f\npsi: %f\ntheta: %f\naltitude: %f\n", [pilot phi], [pilot psi], [pilot theta], [pilot altitude]);
    
    NSTimer *updateTimer = [NSTimer timerWithTimeInterval:1.0f/30.0f target:self selector:@selector(idle:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
}

- (void) awakeFromNib {
    pilot = [KPilot new];
    [pilot initPilot];
    
    wiimote = [Wiimote new];
    [wiimote setDelegate:self];
    
    isTrue = [NSNumber numberWithBool:TRUE];
    isFalse = [NSNumber numberWithBool:FALSE];
    
    isDroneAscending = nil;
    isDroneTurningRight = nil;
    [self update];
    
    [wiimoteBatteryLevelIndicator setMaxValue:kBatteryMaxValue];
    [wiimoteBatteryLevelIndicator setCriticalValue:kBatteryCriticalValue];
    [wiimoteBatteryLevelIndicator setWarningValue:kBatteryWarningValue];
    
    [droneBatteryLevelIndicator setMaxValue:kBatteryMaxValue];
    [droneBatteryLevelIndicator setCriticalValue:kBatteryCriticalValue];
    [droneBatteryLevelIndicator setWarningValue:kBatteryWarningValue];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryStarted:) name:WiimoteBeginDiscoveryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wiimoteDiscoveryEnded:) name:WiimoteEndDiscoveryNotification object:nil];
    
    // register to listen for window closing to clean up
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeApplication) name:NSWindowWillCloseNotification object:nil];
    
    [[WiimoteWatchdog sharedWatchdog] setEnabled:YES];
    [self resetWiimoteStatus];
    
    // do a first look up on startup
    [Wiimote beginDiscovery];
}

- (void)closeApplication
{
    [wiimote disconnect];
    
}
- (IBAction)toggleWiimoteConnection:(id)sender
{
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
    
    [wiimoteBatteryLevelIndicator setDoubleValue:0.0];
    [wiiZ setStringValue:@""];
    [wiiX setStringValue:@""];
    [wiiY setStringValue:@""];
    [wiiRollText setStringValue:@""];
    [wiiPitchText setStringValue:@""];
}

- (void)wiimote:(Wiimote*)wiimote
  buttonPressed:(WiimoteButtonType)button
{
    isWiiButtonPressed = TRUE;
    
    switch(button) {
        case WiimoteButtonTypeMinus:
            //NSLog(@"Button: Minus\n");
            [self resetWiimoteStatus];
            [[self wiimote] disconnect];
            isWiimoteConnected = FALSE;
            break;
        case WiimoteButtonTypeOne:
            //NSLog(@"Button: One\n");
            isWiimoteOrientationVertical = TRUE;
            [wiimoteOrientationButton setFrameCenterRotation:0];
            [[self wiimote] setHighlightedLEDMask:1];
            break;
        case WiimoteButtonTypeTwo:
            //NSLog(@"Button: Two\n");
            isWiimoteOrientationVertical = FALSE;
            [wiimoteOrientationButton setFrameCenterRotation:90];
            [[self wiimote] setHighlightedLEDMask:2];
            break;
        case WiimoteButtonTypeA:
            //NSLog(@"Button: A\n");
            [[self wiimote] playConnectEffect];
            [pilot takeOff];
            [ardroneFlyingStatus setStringValue: @"Taking Off"];
            break;
        case WiimoteButtonTypeB:
            //NSLog(@"Button: B\n");
            [pilot land];
            [ardroneFlyingStatus setStringValue: @"Landing Down"];
            break;
        case WiimoteButtonTypeHome:
            //NSLog(@"Button: Home\n");
            [ardroneFlyingStatus setStringValue: @"Emergency"];
            [pilot emergency];
            break;
        case WiimoteButtonTypeDown:
            //NSLog(@"Button: Down\n");
            if(isWiimoteOrientationVertical) [pilot descend];
            else [pilot rotateRight];
            break;
        case WiimoteButtonTypeUp:
            //NSLog(@"Button: Up\n");
            if(isWiimoteOrientationVertical) [pilot ascend];
            else [pilot rotateLeft];
            break;
        case WiimoteButtonTypeRight:
            //NSLog(@"Button: Right\n");
            if(isWiimoteOrientationVertical) [pilot rotateRight];
            else [pilot ascend];
            break;
        case WiimoteButtonTypeLeft:
            //NSLog(@"Button: Left\n");
            if(isWiimoteOrientationVertical) [pilot rotateLeft];
            else [pilot descend];
            break;
        default:
            isWiiButtonPressed = FALSE;
            break;
    }
}

- (void)wiimote:(Wiimote*)wiimote
 buttonReleased:(WiimoteButtonType)button
{
    isWiiButtonPressed  = FALSE;
    isDroneAscending    = nil;
    isDroneTurningRight = nil;
    [pilot hover];
}


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
    
    if (isWiimoteOrientationVertical) {
        theta = -roll / kAngleThreshold;
        phi = -pitch / kAngleThreshold;
        
    } else {
        theta = -pitch / kAngleThreshold;
        phi = roll / kAngleThreshold;
    }
    
    
    if(theta > 1.0f) theta = 1.0f;
    else if(theta < -1.0f) theta = -1.0f;
    
    if(phi > 1.0f) phi = 1.0f;
    else if(phi < -1.0f) phi = -1.0f;

    [pilot moveTheta: theta phi: phi];
    
    // set the battery state
    // TODO: This needs to be moved into a responder where we can independently set the batteryLevel
    // PRIORITY: Very low due to possible performance hit (minor) for waiting on a separate message, and battery level just isn't that valuable for the wiimote
    [wiimoteBatteryLevelIndicator setDoubleValue:[[self wiimote] batteryLevel]];
}

@end
