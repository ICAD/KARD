//
//  main.cpp
//  KARD
//
//  Created by Tyler on 2012-10-09.
//  Copyright (c) 2012 ICAD. All rights reserved.
//
#include "kard.h"

#include <string.h>

// OpenGL Windows
int kKINECT_WINDOW = 0;
int kARDRONE_STATUS_WINDOW = 0;
int kARDRONE_VIDEO_WINDOW = 0;

void kInitGLUT() {
    int pargc = 1;
    char *pargv[] = { "KARD Project", NULL };
    glutInit(&pargc, pargv);
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
}

void kRenderWindows() {
    if(kKINECT_WINDOW) {
        //printf("Rendering Kinect Window\n");
        glutSetWindow(kKINECT_WINDOW);
        kvRenderTrackingScene();
    }
    
    if(kARDRONE_STATUS_WINDOW) {
        glutSetWindow(kARDRONE_STATUS_WINDOW);
        kpRenderVIDEO();
        //glutReshapeFunc (reshape);
        
    }
    
    //if(kARDRONE_VIDEO_WINDOW) {
  //      glutSetWindow(kARDRONE_VIDEO_WINDOW);
  //      kpRenderVideo();
  //  }
}

void kRenderOpenGL() {
    printf("Started OpenGL Thread\n");
    glutIdleFunc(kRenderWindows);
    //glutMainLoop();
}

int main(int argc, char * argv[]) {
    XnBool kUSE_ARDRONE = TRUE;
    XnBool kUSE_VISION = FALSE;

	//if(argc > 1) {
	//	if(strcmp("kinect", argv[1]) == 0) {
	//		kUSE_VISION = TRUE;
	//	} else if(strcmp("ardrone", argv[1]) == 0) {
	//		kUSE_ARDRONE = TRUE;
	//	} else if(strcmp("both", argv[1]) == 0) {
	//		kUSE_VISION = TRUE;
	//		kUSE_ARDRONE = TRUE;
	//	} else {
	//		printf("Please enter an option to use: kinect, ardrone or both\n");
	//		return 0;
	//	}
	//}
    // initialize the OpenGL context
    kInitGLUT();
    //ardrone_tool_main(argc, argv);
    // check what functionality to run as
    if(kUSE_ARDRONE && kUSE_VISION) {
        printf("KARD: Using both vision/pilot\n");
        kvInitTracking(&kKINECT_WINDOW);
        //kpInitHUD(&kARDRONE_STATUS_WINDOW);
        return C_OK;
    } else if(kUSE_VISION) {
        printf("KARD: Using only vision\n");
        kvInitTracking(&kKINECT_WINDOW);
        kRenderOpenGL();
        return C_OK;
    } else if(kUSE_ARDRONE) {
        printf("KARD: Using only pilot\n");
        kpInitVIDEO(&kARDRONE_STATUS_WINDOW);
        ardrone_tool_main(argc, argv);
        //printf("am i printing this \n");
        //kRenderOpenGL();
        
    }
        
return C_FAIL;
}

DEFINE_THREAD_ROUTINE(opengl, data) {
    kRenderOpenGL();
    printf("I am running this");
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
