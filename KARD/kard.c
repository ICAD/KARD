//
//  main.cpp
//  KARD
//
//  Created by Tyler on 2012-10-09.
//  Copyright (c) 2012 ICAD. All rights reserved.
//
#include "kard.h"

#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <GLUT/glut.h>
#include <OpenGL/glext.h>
#elif __linux
#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/glext.h>
#endif

#include <string.h>

XnBool kUSE_ARDRONE = TRUE;
XnBool kUSE_VISION = FALSE;

enum KARD_WINDOW_ENUM {
    KARD_WINDOW_WIDTH   = 640,
    KARD_WINDOW_HEIGHT  = 480,
    KARD_WINDOW_X       = 300,
    KARD_WINDOW_Y       = 100
};

void kdPrintText(float x, float y, float z, float r, float g, float b, float a, char * text) {
    glColor4f(r,g,b,a);
    glRasterPos3d(x,y,z);
    
    //glLoadIdentity();
    int limit = strlen(text);
    int counter = -1;
    while(counter++ <  limit - 1) {
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12, text[counter]);
    }
    
}

void kpShowStatus() {
    float x = 0.02;
    float y = -0.05;
    
    kdPrintText(x, y-=0.07, 0, 1, 1, 1, 1, "Battery: ");
    kdPrintText(x, y-=0.07, 0, 1, 1, 1, 1, "Height: ");
    kdPrintText(x, y-=0.07, 0, 1, 1, 1, 1, "Psi: ");
}
// function: kvRenderScene
// description: renders the GL context
void kvRenderScene2() {
    // clear the GL buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    kpShowStatus();
    
    glBegin(GL_LINES);
        glVertex3f(0,0,0);
        glVertex3f( 1, 1, 1);
    glEnd();
    glutSwapBuffers();
}


int main(int argc, char * argv[])
{
    
    //XnBool kUSE_ARDRONE = FALSE;
    /*
    if(kUSE_ARDRONE && kUSE_VISION) {
        printf("KARD: Using both vision/pilot\n");
        if(kvInitVision(argc, argv) == XN_STATUS_OK) {
            kpInitPilot(argc, argv);
            return ardrone_tool_main(argc, argv);
        }
        return C_FAIL;
    } else if(kUSE_VISION) {
        printf("KARD: Using only vision\n");
        if(kvInitVision(argc, argv) == XN_STATUS_OK) {
            kvStartVision();
        }
        
        return C_OK;
    } else if(kUSE_ARDRONE) {
        printf("KARD: Using only pilot\n");
        kpInitPilot(argc, argv);
        return ardrone_tool_main(argc, argv);
    }*/
    
    kpInitPilot(argc, argv);
    
    
    // fake init params
	int pargc = 1;
	char *pargv[] = { "KARD Vision", NULL };
    
    glutInit(&pargc, pargv);
    
    
    kvInitScene();
    
    glutDisplayFunc((void *)kvRenderScene2);
    glutIdleFunc((void *)kvRenderScene2);

    kvStartVision();
    
}

DEFINE_THREAD_ROUTINE(kinect, data) {
    printf("video\n");
    if(kUSE_VISION) { kvStartVision(); }
    return C_OK;
}

DEFINE_THREAD_ROUTINE(main_application_thread, data) {

    return C_OK;
}