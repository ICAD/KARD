//
//  threads.h
//  KARD
//
//  Created by Tyler on 2012-10-10.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#ifndef KARD_threads_h
#define KARD_threads_h

#endif

#include "api.h"
#include <ardrone_control.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <ardrone_tool/Control/ardrone_control.h>
#include <VP_Os/vp_os_types.h>

#include "navdata.h"
//#include "controller.h"
#include <curses.h>

/* The delegate object calls this method during initialization of an ARDrone application */
C_RESULT ardrone_tool_init_custom(void);

/* The delegate object calls this method when the event loop exit */
C_RESULT ardrone_tool_shutdown_custom(void);

/* The event loop calls this method for the exit condition */
bool_t ardrone_tool_exit();
C_RESULT signal_exit();

/* KARD's main application thread */
PROTO_THREAD_ROUTINE(kinect, data);
PROTO_THREAD_ROUTINE(main_application_thread, data);