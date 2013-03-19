//
//  KPilotVision.m
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import "KPilotView.h"
#import "AppDelegate.h"
#include <ardrone_api.h>
#include <signal.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>
//#include "../vision/vision.h"
//#include "navdata.h"

@implementation KPilotView

@synthesize batteryLevel, delegate;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    
    return self;
}

- (void) awakeFromNib {
    NSLog(@"Awaken\n");
	loadTexture_Ipl( img, &texture );
    
}


//============================================================
// GLOBALS
//============================================================
static GLuint      texture;

static GLuint texture; //the array for our texture
GLfloat angle = 0.0;




- (void) initScene
{
    glutReshapeFunc (reshape);
    glTranslatef(-1, 1, 0);
}

void plane (void) {
	glBindTexture( GL_TEXTURE_2D, texture ); //bind the texture
    //glRotatef( angle, 1.0f, 1.0f, 1.0f );
    glBegin (GL_QUADS);
    glTexCoord2d(0.0,0.0); glVertex2d(-1.0,-1.0); //with our vertices we have to assign a texcoord
    glTexCoord2d(1.0,0.0); glVertex2d(+1.0,-1.0); //so that our texture has some points to draw to
    glTexCoord2d(1.0,1.0); glVertex2d(+1.0,+1.0);
    glTexCoord2d(0.0,1.0); glVertex2d(-1.0,+1.0);
    glEnd();
    
}

void reshape (int w, int h) {
    NSLog(@"\n\nprint me\n\n");
    glViewport (0, 0, w, h);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity ();
    gluPerspective (45, w/h, 0.1f, 100.0);
    glScalef(1, -1, 1);
    glMatrixMode (GL_MODELVIEW);
}

-(void)reshape
{
	NSLog(@"reshaping...");
	NSRect bounds = [self bounds];
	glViewport(0, 0, NSWidth(bounds), NSHeight(bounds));
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    gluPerspective (45, NSWidth(bounds)/NSHeight(bounds), 1, 1000.0);
    glScalef(1, -1, 1);
    glMatrixMode (GL_MODELVIEW);
}


int loadTexture_Ipl(IplImage *image, GLuint *text) {
    
    if (image==NULL) return -1;
    
    glGenTextures(3, text);
    
	glBindTexture( GL_TEXTURE_2D, *text ); //bind the texture to it's array
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image->width, image->height,0, GL_BGR, GL_UNSIGNED_BYTE, image->imageData);
    return 0;
    
}

// function: renderScene
// description: renders the GL context
- (void) renderScene
{
    glClearColor (0.0,0.0,0.0,1.0);
    glClear (GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    glClearColor (0.0,0.0,0.0,1.0);
    gluLookAt (0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    glEnable( GL_TEXTURE_2D ); //enable 2D texturing
	loadTexture_Ipl( img, &texture );
    plane();
    glutSwapBuffers();
    [[self openGLContext] flushBuffer] ;
    
}




- (void)idle:(NSTimer*)timer
{
    [self setNeedsDisplay:YES];
}



- (void)initPilotView
{
    //NSLog(@"InitPilotView\n");
    //glutReshapeFunc(reshape);
    //glTranslatef(-1, 1, 0);
}

- (void) update
{
    [self renderScene];
    NSTimer *updateTimer = [NSTimer timerWithTimeInterval:1.0f/30.0f target:self selector:@selector(idle:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
    glFlush();
    glDeleteTextures( 1, &texture );
}


- (void)drawRect:(NSRect)dirtyRect
{
    [self initPilotView];
    [self update];
}


@end
