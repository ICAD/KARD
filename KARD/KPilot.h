//
//  KPilot.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "KARD-Prefix.pch"

#include <ardrone_api.h>
#include <signal.h>
//#include "../vision/vision.h"
#include "navdata.h"

// ARDrone Tool includes
#include <ardrone_tool/ardrone_tool.h>
#include <ardrone_tool/ardrone_tool_configuration.h>
#include <ardrone_tool/ardrone_version.h>
#include <ardrone_tool/Video/video_stage_decoder.h>
#include <ardrone_tool/Video/video_stage.h>
#include <ardrone_tool/Video/video_recorder_pipeline.h>
#include <ardrone_tool/Navdata/ardrone_navdata_client.h>
#include <ardrone_tool/Control/ardrone_control.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <ardrone_tool/Control/ardrone_control.h>
#include <VP_Os/vp_os_types.h>
// System Libraries
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <stddef.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#ifdef __linux
#include <linux/input.h>
#endif
#include <sys/ioctl.h>
// Video Stages
#include "pilot/video/pre_stage.h"
#include "pilot/video/display_stage.h"

@interface KPilot : NSObject

- (void) kpInitPilot;
- (void) kpInitHUD:(int *) window;
- (void) kpRenderHUD;
- (void) kpRenderVideo;
@end
