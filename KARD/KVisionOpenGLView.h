//
//  KVisionView.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#include "KARD-Prefix.pch"

#include <stdio.h>
#include <math.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <ardrone_tool/Control/ardrone_control.h>

@interface KVisionOpenGLView : NSOpenGLView
//------------------------------------------------------------
// KARD VISION INITIALIZER
//------------------------------------------------------------
// function: kvInitVision()
// description: initializes the OpenNI contexts
- (BOOL) initTracking;

//------------------------------------------------------------
// OPENGL
//------------------------------------------------------------
// function: initScene
// description: initializes the GL Scene
- (void) initScene;
@end
