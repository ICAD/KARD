//
//  KPilot.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#include "KARD-Prefix.pch"
#include "KPilotView.h"

enum KARD_WINDOW_ENUM {
    KARD_WINDOW_WIDTH   = 640,
    KARD_WINDOW_HEIGHT  = 480,
    KARD_WINDOW_X       = 300,
    KARD_WINDOW_Y       = 100
};

@interface KPilot : NSObject
@property (strong, nonatomic) KPilotView * pilotView;

- (void) initPilot;
- (void) initHUD;
- (void) renderHUD;
- (void) renderVideo;

- (void) takeOff;
- (void) land;
- (void) descend;
- (void) ascend;
- (void) hover;
- (void) emergency;
- (void) rotateRight;
- (void) rotateLeft;
- (void) moveTheta: (float) theta
               phi: (float) phi
               gaz: (float) gaz
               yaw: (float) yaw;

- (void) moveTheta: (float) theta phi: (float) phi;

- (BOOL) isFlying;
- (CGFloat) batteryLevel;
- (CGFloat) phi;
- (CGFloat) psi;
- (CGFloat) theta;
- (CGFloat) altitude;
@end
