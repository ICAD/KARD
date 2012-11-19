//
//  kard.h
//  KARD
//
//  Created by Tyler on 2012-10-15.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#ifndef KARD_kard_h
#define KARD_kard_h

// Local Headers
#include "api.h"
//#include "control.h"
#include "navdata.h"
#include <ardrone_control.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <ardrone_tool/ardrone_tool.h>
#include <ardrone_tool/ardrone_version.h>
#include <ardrone_tool/Control/ardrone_control.h>
#include <ardrone_tool/ardrone_tool_configuration.h>
#include <ardrone_tool/ardrone_tool.h>
#include <ardrone_tool/ardrone_tool_configuration.h>
#include <ardrone_tool/ardrone_version.h>
#include <ardrone_tool/Video/video_stage.h>
#include <ardrone_tool/Video/video_recorder_pipeline.h>
#include <ardrone_tool/Navdata/ardrone_navdata_client.h>
#include <VP_Os/vp_os_types.h>

#include "Video/display_stage.h"
#include "Video/pre_stage.h"
#include "Video/post_stage.h"
#include <cv.h>
#include <highgui.h>

/* The delegate object calls this method during initialization of an ARDrone application */
C_RESULT ardrone_tool_init_custom(void);

/* The delegate object calls this method when the event loop exit */
C_RESULT ardrone_tool_shutdown_custom(void);

/* The event loop calls this method for the exit condition */
bool_t ardrone_tool_exit();
C_RESULT signal_exit();

/* KARD's main application thread */
PROTO_THREAD_ROUTINE(main_application_thread, data);
PROTO_THREAD_ROUTINE(gtk, data);

/* Implementing thread table in which you add routines of your application and those provided by the SDK */
BEGIN_THREAD_TABLE
    THREAD_TABLE_ENTRY( kinect, 20 )
    THREAD_TABLE_ENTRY( main_application_thread, 20 )
    THREAD_TABLE_ENTRY( ardrone_control, 20 )
    THREAD_TABLE_ENTRY( navdata_update, 20 )
    THREAD_TABLE_ENTRY(video_stage, 20)
    THREAD_TABLE_ENTRY(video_recorder, 20)
    THREAD_TABLE_ENTRY(gtk, 20)
END_THREAD_TABLE


/* Registering to navdata client */
BEGIN_NAVDATA_HANDLER_TABLE
    NAVDATA_HANDLER_TABLE_ENTRY(demo_navdata_client_init, demo_navdata_client_process, demo_navdata_client_release, NULL)
END_NAVDATA_HANDLER_TABLE




CvCapture * capture;
IplImage * frame;
IplImage * dst;

#endif
