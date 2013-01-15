//
//  main.cpp
//  KARD
//
//  Created by Tyler on 2012-10-09.
//  Copyright (c) 2012 ICAD. All rights reserved.
//
#include "kard.h"

#include <string.h>

XnBool kUSE_ARDRONE = TRUE;
XnBool kUSE_VISION = FALSE;

void kInitGLUT() {
    //init params for GLUT
    int pargc = 1;
    char *pargv[] = { "KARD Vision", NULL };
    glutInit(&pargc, pargv);
    
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
}

void * startARDrone(void *arg) {
    int argc = 0;
    char * argv[] = { "", NULL };
    
    kpInitPilot(argc, argv);
    printf("Finished initializing AR.Drone.\nStarting AR.Drone Main Loop\n");
    printf("Finished running ardrone_tool_main\n");
    printf("Initialized\n");
}

int main(int argc, char * argv[]) {
    //kInitGLUT();
    
    // check what functionality to run as
    if(kUSE_ARDRONE && kUSE_VISION) {
        printf("KARD: Using both vision/pilot\n");
        if(kvInitVision(argc, argv) == XN_STATUS_OK) {
            kpInitPilot(argc, argv);
            return ardrone_tool_main(argc, argv);
        }
        return C_OK;
    } else if(kUSE_VISION) {
        printf("KARD: Using only vision\n");
        if(kvInitVision(argc, argv) == XN_STATUS_OK) {
            kvStartVision();
        }
        
        return C_OK;
    } else if(kUSE_ARDRONE) {
        printf("KARD: Using only pilot\n");
        // fork threads
        // create thread for AR.Drone
        //pthread_t threadARDrone;
        
        //pthread_create(&threadARDrone, NULL, &startARDrone, NULL);
        //pthread_join(threadARDrone, NULL);
        
        // call the main loop
        return ardrone_tool_main(argc, argv);
    } else {
        return C_FAIL;
    }
}

DEFINE_THREAD_ROUTINE(kinect, data) {
    printf("video\n");
    if(kUSE_VISION) { kvStartVision(); }
    //else { glutMainLoop(); }
    
    kpInitHUD();
    printf("Starting glutMainLoop()");
    glutMainLoop();
    return C_OK;
}

DEFINE_THREAD_ROUTINE(main_application_thread, data) {
    
    //int pargc = 1;
    //char *pargv[] = { "KARD Visions", NULL };
    //glutInit(&pargc, pargv);
    
    //glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
    
    //kpInitHUD();
    printf("Starting glutMainLoop()");
    //glutMainLoop();
    return C_OK;
}