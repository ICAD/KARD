//
//  main.cpp
//  KARD
//
//  Created by Tyler on 2012-10-09.
//  Copyright (c) 2012 ICAD. All rights reserved.
//
#include <stdio.h>
#include <Common/config.h>
#include <ardrone_api.h>
#include <ardrone_tool.h>
#include <ardrone_tool/Navdata/ardrone_navdata_client.h>
#include <ardrone_tool/Control/ardrone_control.h>

/* Registering to navdata client */
BEGIN_NAVDATA_HANDLER_TABLE
//NAVDATA_HANDLER_TABLE_ENTRY(demo_navdata_client_init, demo_navdata_client_process, demo_navdata_client_release, NULL)
END_NAVDATA_HANDLER_TABLE

/* Implementing thread table in which you add routines of your application and those provided by the SDK */
BEGIN_THREAD_TABLE
//THREAD_TABLE_ENTRY( ardrone_control, 20 )
//THREAD_TABLE_ENTRY( navdata_update, 20 )
//THREAD_TABLE_ENTRY( video_stage, 20 )
END_THREAD_TABLE

int main(int argc, char * argv[])
{
    
    C_RESULT res;
    
    res = ardrone_tool_setup_com( NULL );
    
    if( VP_FAILED(res) )
    {
        printf("Wifi initialization failed. It means either:\n");
        printf("\t* you're not root (you can set up wifi connection only as root)\n");
        printf("\t* wifi device is not present (on your pc or on your card)\n");
        printf("\t* you set the wrong name for wifi interface (for example rausb0 instead of wlan0) \n");
        printf("\t* ap is not up (reboot card or remove wifi usb dongle)\n");
        printf("\t* wifi device has no antenna\n");
    }
    else
    {
        res = ardrone_tool_main(argc, argv);
        
        while( VP_SUCCEEDED(res) && ardrone_tool_exit() == FALSE )
        {
            res = ardrone_tool_update();
        }
        
        res = ardrone_tool_shutdown();
    }

    
    return 0;
}