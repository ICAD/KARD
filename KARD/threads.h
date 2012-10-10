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

#include <stdio.h>
#include <unistd.h>
#include <Common/config.h>
#include <ardrone_api.h>
#include <ardrone_tool.h>
#include <ATcodec/ATcodec_api.h>
#include <VP_Os/vp_os_print.h>
#include <VP_Os/vp_os_signal.h>
#include <ardrone_tool/video/video_com_stage.h>
#include <ardrone_tool/Video/video_stage.h>
#include <ardrone_control.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <curses.h>
#include <ardrone_tool/Navdata/ardrone_navdata_client.h>
#include <ardrone_tool/Control/ardrone_control.h>
#include <VP_Api/vp_api_thread_helper.h>

/* Constants */
#define RECORDING_PORT      5553 //TCP
#define NAVDATA_PORT        5554 //UDP
#define VIDEO_PORT          5555 //TCP
#define AT_PORT             5556 //UDP
#define VIDEO_CONTROL_PORT  5559 //TCP
#define AT_BUFFER_SIZE      1024 

/* Initialization local variables before event loop  */
C_RESULT demo_navdata_client_init( void* data );

/* Receving navdata during the event loop */
C_RESULT demo_navdata_client_process( const navdata_unpacked_t* const navdata );

/* Relinquish the local resources after the event loop exit */
C_RESULT demo_navdata_client_release( void );


/* The delegate object calls this method during initialization of an ARDrone application */
C_RESULT ardrone_tool_init_custom(void);

/* The delegate object calls this method when the event loop exit */
C_RESULT ardrone_tool_shutdown_custom(void);

/* The event loop calls this method for the exit condition */
bool_t ardrone_tool_exit();
C_RESULT signal_exit();

/* KARD's main application thread */
PROTO_THREAD_ROUTINE(main_application_thread, data);