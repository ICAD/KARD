//
//  KPilotVision.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "display_stage.h"

@interface KPilotView : NSOpenGLView

@property (nonatomic, retain) IBOutlet NSTextField * batteryLevel;

- (void)initPilotView;

@end
