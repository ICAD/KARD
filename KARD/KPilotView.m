//
//  KPilotVision.m
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import "KPilotView.h"

@implementation KPilotView


static float red = 0.0;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

static void drawAnObject ()

{
    red += 0.01;
    if(red >= 1.0) {
        red = 0;
    }
    
    glColor3f(red, 0, 0);
    
    glBegin(GL_TRIANGLES);
    
    {
        
        glVertex3f(  0.0,  0.6, 0.0);
        
        glVertex3f( -0.2, -0.3, 0.0);
        
        glVertex3f(  0.2, -0.3 ,0.0);
        
    }
    
    glEnd();
}

- (void)idle:(NSTimer*)timer
{
    [self setNeedsDisplay:YES];
}

- (void) update {
    NSTimer *updateTimer = [NSTimer timerWithTimeInterval:1.0f/30.0f target:self selector:@selector(idle:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    glClearColor(0, 0, 0, 0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    //drawAnObject();
    [self update];
    glFlush();
}

@end
