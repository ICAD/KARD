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
#include "control.h"
#include "navdata.h"

/* Implementing thread table in which you add routines of your application and those provided by the SDK */
BEGIN_THREAD_TABLE
    THREAD_TABLE_ENTRY( kinect, 20 )
    THREAD_TABLE_ENTRY( main_application_thread, 20 )
    THREAD_TABLE_ENTRY( ardrone_control, 20 )
    THREAD_TABLE_ENTRY( navdata_update, 20 )
    THREAD_TABLE_ENTRY( video_stage, 20 )
END_THREAD_TABLE


/* Registering to navdata client */
BEGIN_NAVDATA_HANDLER_TABLE
    NAVDATA_HANDLER_TABLE_ENTRY(demo_navdata_client_init, demo_navdata_client_process, demo_navdata_client_release, NULL)
END_NAVDATA_HANDLER_TABLE

#endif
