//
//  KPilot.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#include "KARD-Prefix.pch"

@interface KPilot : NSObject

- (void) initPilot;
- (void) initHUD;
- (void) renderHUD;
- (void) renderVideo;

- (void) takeOff;
- (void) land;
- (void) moveTheta: (float) theta phi: (float) phi;
@end
