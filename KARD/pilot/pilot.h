// Generic includes
#include "api.h"
#include <ardrone_api.h>
#include <signal.h>
#include "../vision/vision.h"

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
#include "video/pre_stage.h"
#include "video/display_stage.h"

void controlCHandler (int signal);

void kpInitPilot(int argc, char *argv[]);
void kpInitHUD();
