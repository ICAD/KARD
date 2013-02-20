//
//  constants.h
//  KARD
//
//  Created by Tyler on 2012-10-15.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#ifndef KARD_constants_h
#define KARD_constants_h

#include <stdio.h>
#include <Soft/Common/ardrone_api.h>
#include <Soft/Common/config.h>
#include <VP_Api/vp_api_thread_helper.h>
#include <ardrone_tool/ardrone_tool.h>


// Video Headers
#include <ATcodec/ATcodec_api.h>
#include <VP_Os/vp_os_print.h>
#include <VP_Os/vp_os_signal.h>
#include <ardrone_tool/Video/video_com_stage.h>
#include <ardrone_tool/Video/video_stage.h>

/* Constants */
#define RECORDING_PORT      5553 //TCP
#define NAVDATA_PORT        5554 //UDP
#define VIDEO_PORT          5555 //TCP
#define AT_PORT             5556 //UDP
#define VIDEO_CONTROL_PORT  5559 //TCP
#define AT_BUFFER_SIZE      1024

// OPENGL
#include <GL/glew.h>
#include <GL/freeglut.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/glext.h>

#endif
