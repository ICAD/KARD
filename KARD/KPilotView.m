//
//  KPilotVision.m
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import "KPilotView.h"
#import "AppDelegate.h"
#include <ardrone_api.h>
#include <signal.h>
//#include "../vision/vision.h"
//#include "navdata.h"

@implementation KPilotView

@synthesize batteryLevel, delegate;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    
    return self;
}

- (void) awakeFromNib {
    NSLog(@"Awaken\n");
}

- (void)idle:(NSTimer*)timer
{
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
    
    //AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    //[[appDelegate pilot] batteryLevel];
    
    //NSString * batteryPercentage = [NSString stringWithFormat:@"%i", nd->vbat_flying_percentage];
    //[batteryLevel setStringValue:batteryPercentage];
}


- (void)initPilotView
{
    NSLog(@"InitPilotView\n");
}



- (void)updateBatteryStatus:(NSString *)batteryStatus {
    if([[self delegate] respondsToSelector:@selector(updateBatteryStatus:)]) {
        [[self delegate] updateBatteryStatus:batteryStatus];
        NSLog(@"Battery: %@\n", batteryStatus);
    }
}
@end
