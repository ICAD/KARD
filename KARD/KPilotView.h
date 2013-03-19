//
//  KPilotVision.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "display_stage.h"

@protocol KPilotViewDelegate <NSObject>
@optional
- (void)updateBatteryStatus:(NSString *)batteryStatus;
// ... other methods here
@end

@interface KPilotView : NSOpenGLView

@property (nonatomic, retain) IBOutlet NSTextField * batteryLevel;
@property (nonatomic, weak) id <KPilotViewDelegate> delegate;

- (void)initPilotView;

@end
