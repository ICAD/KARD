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
#include "math.h"
//#include "control.h"
#include "vision/vision.h"
#include "navdata/navdata.h"
#include "pilot/pilot.h"

PROTO_THREAD_ROUTINE(opengl, data);
PROTO_THREAD_ROUTINE(main_application_thread, data);

/**
 * Declare Threads / Navdata tables
 */
BEGIN_THREAD_TABLE
    THREAD_TABLE_ENTRY( opengl, 20 )
    THREAD_TABLE_ENTRY( ardrone_control, 20 )
    THREAD_TABLE_ENTRY( navdata_update, 20 )
    THREAD_TABLE_ENTRY( video_stage, 20 )
    THREAD_TABLE_ENTRY( video_recorder, 20)
    THREAD_TABLE_ENTRY( main_application_thread, 20 )
END_THREAD_TABLE

BEGIN_NAVDATA_HANDLER_TABLE
    NAVDATA_HANDLER_TABLE_ENTRY(demo_navdata_client_init, demo_navdata_client_process, demo_navdata_client_release, NULL)
END_NAVDATA_HANDLER_TABLE

#endif
