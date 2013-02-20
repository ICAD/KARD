//
//  KVisionView.h
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#include "KARD-Prefix.pch"

@interface KVisionOpenGLView : NSOpenGLView
//------------------------------------------------------------
// KARD VISION INITIALIZER
//------------------------------------------------------------
// function: initTracking
// description: initializes the OpenNI contexts
- (BOOL) initTracking;

//------------------------------------------------------------
// OPENGL
//------------------------------------------------------------
// function: initScene
// description: initializes the GL Scene
- (void) initScene;
@end
