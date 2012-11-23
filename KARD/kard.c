//
//  main.cpp
//  KARD
//
//  Created by Tyler on 2012-10-09.
//  Copyright (c) 2012 ICAD. All rights reserved.
//
#include "kard.h"

int main(int argc, char * argv[])
{
    if(1) {
        kvInitVision(argc, argv);
        return ardrone_tool_main(argc, argv);
    } else {
        if(kvInitVision(argc, argv) == XN_STATUS_OK) {
            kvStartVision();
        }
        
        return C_OK;
    }
}

DEFINE_THREAD_ROUTINE(kinect, data) {
    printf("video\n");
    kvStartVision();
    return C_OK;
}

DEFINE_THREAD_ROUTINE(main_application_thread, data) {

    return C_OK;
}