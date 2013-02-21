//
//  KVisionView.m
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import "KVisionOpenGLView.h"
#include "AppDelegate.h"
#include <stdio.h>
#include <math.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <ardrone_tool/Control/ardrone_control.h>
#include <ardrone_tool/UI/ardrone_input.h>
#include <ardrone_tool/Control/ardrone_control.h>

@implementation KVisionOpenGLView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    [[self window] setAcceptsMouseMovedEvents:YES];
    //BOOL tracking = [self initTracking];
}

//============================================================
// GLOBALS
//============================================================
// NI Contexts/Production Nodes
//------------------------------------------------------------
XnContext       *   kvCONTEXT_PTR;
XnNodeHandle        kvUSER_NODE_HANDLE;
XnNodeHandle        kvDEPTH_NODE_HANDLE;
XnDepthMetaData *   kvDEPTH_MD_PTR;
//------------------------------------------------------------
// State Flags
//------------------------------------------------------------
XnBool              kvDRAW_BONES = TRUE;        // Bone Lines
XnBool              kvDRAW_BOUNDARIES = TRUE;   // Scene Bounds
XnBool              kvIS_FLYING = FALSE;
//------------------------------------------------------------
// Registration Points
//------------------------------------------------------------
float               kvLIMIT_HAND_UPPER = 230.0; // NEED TO SET THIS IN CALIBRATION
float               kvLIMIT_HAND_LOWER = -120.0; // SET THIS IN CALIBRATION
float               kvLIMIT_DEADZONE_UPPER_Y = 60;
float               kvLIMIT_DEADZONE_LOWER_Y = -60;
float               kvLIMIT_CENTER_Y = 0.0;
float               kvLIMIT_CENTER_X = 0.0;
float               kvLIMIT_TORSO_Y;
float               kvLIMIT_TORSO_X;
float               kvLIMIT_HEAD_UPPER_Y;
float               kvLIMIT_HEAD_LOWER_Y;
int                 kvHOVER_LIMIT = 70;
XnPoint3D           kvORIGIN = { .X = 0.0, .Y = 0.0, .Z = 0.0 };
XnPoint3D           kvRHAND_ORIGIN = { .X = 0.0, .Y = 0.0, .Z = 0.0 };
XnPoint3D           kvLHAND_ORIGIN = { .X = 0.0, .Y = 0.0, .Z = 0.0 };
int                 kvORIGIN_LIMIT_Z = 120;
int                 kvORIGIN_LIMIT_X = 120;

//------------------------------------------------------------
// Boundary Active Flags
//------------------------------------------------------------
float               kvHAND_ACTIVE = FALSE;
//------------------------------------------------------------
// Colors
//------------------------------------------------------------
// FLY
float               kvCOLOR_FLY_R = 173.0/255.0;
float               kvCOLOR_FLY_G = 255.0/255.0;
float               kvCOLOR_FLY_B = 47.0/255.0;
// LAND
float               kvCOLOR_LAND_R = 255.0/255.0;
float               kvCOLOR_LAND_G = 0.0/255.0;
float               kvCOLOR_LAND_B = 0.0/255.0;
// ACTIVE
float               kvCOLOR_ACTIVE_R = 255.0/255.0;
float               kvCOLOR_ACTIVE_G = 165.0/255.0;
float               kvCOLOR_ACTIVE_B = 0.0/255.0;

//============================================================
// ENUMS
//============================================================
enum KARD_WINDOW_ENUM {
    KARD_WINDOW_WIDTH   = 640,
    KARD_WINDOW_HEIGHT  = 480,
    KARD_WINDOW_X       = 300,
    KARD_WINDOW_Y       = 100
};

//============================================================
// DEFINES
//============================================================
#define SAMPLE_XML_PATH "SamplesConfig.xml"

#define CHECK_RC(rc, what)	\
if (rc != XN_STATUS_OK) { \
    printf("%s failed: %s\n", what, xnGetStatusString(rc));	\
    return rc; \
}

//------------------------------------------------------------
// KEYPRESS SIMULATIONS
//------------------------------------------------------------
// function: kvKeyPress()
// description: delegate for GLUT Keydown
// TODO: Add this functionality to OpenGL instead of GLUT
void kvKeyPress(int key, int x, int y) {
    switch (key) {
        case GLUT_KEY_LEFT :
            printf("VISION: KEYDOWN LEFT\n");
            break;
        case GLUT_KEY_RIGHT :
            printf("VISION: KEYDOWN RIGHT\n");
            break;
        case GLUT_KEY_UP :
            printf("VISION: KEYDOWN UP\n");
            break;
        case GLUT_KEY_F5:
            printf("VISION: TOGGLE BONES\n");
            kvDRAW_BONES = !kvDRAW_BONES;
            break;
        case GLUT_KEY_F6:
            printf("VISION: TOGGLE BOUNDARIES\n");
            kvDRAW_BOUNDARIES = !kvDRAW_BOUNDARIES;
            break;
        case GLUT_KEY_DOWN:
            printf("VISION: TOGGLE EMERGENCY\n");
            break;
        default:
            // no handle
            break;
    }
}

// function: kvKeyRelease()
// description: delegate for GLUT Keyup
void kvKeyRelease(int key, int x, int y) {
    switch (key) {
        case GLUT_KEY_LEFT :
            printf("VISION: KEYUP LEFT\n");
            break;
        case GLUT_KEY_RIGHT :
            printf("VISION: KEYUP RIGHT\n");
            break;
        case GLUT_KEY_UP :
            printf("VISION: KEYUP UP\n");
            break;
        case GLUT_KEY_DOWN :
            printf("VISION: KEYUP DOWN\n");
            break;
        default:
            // no handle
            break;
    }
}

//------------------------------------------------------------
// OPENGL
//------------------------------------------------------------
// function: initScene()
// description: initializes the GL Scene
- (void) initScene
{
    glClearColor(0, 0, 0, 0);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glTranslatef(-1, 1, 0);
}

// function: renderScene
// description: renders the GL context
- (void) renderScene
{
    glLoadIdentity();
    static float angle = 0.0f, deltaAngle = 0.0f;
    //float handOffsetY = 0.4f;
    
    angle += deltaAngle;
    
    [self orientMe:angle];
    
    // clear the GL buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // set the domain lines for user actions
    glColor3f(0.9f, 0.0f, 0.0f);
    glLineWidth(2.0f);
    
    if(kvDRAW_BOUNDARIES) {
        //---------------------
        // DRAW SCENE BOUNDARIES
        //---------------------
        
        // set color feedback for Drone state
        if (kvHAND_ACTIVE) {
            glColor3f( kvCOLOR_ACTIVE_R, kvCOLOR_ACTIVE_G, kvCOLOR_ACTIVE_B );
        } else if (kvIS_FLYING) {
            glColor3f( kvCOLOR_FLY_R, kvCOLOR_FLY_G, kvCOLOR_FLY_B );
        } else {
            glColor3f( kvCOLOR_LAND_R, kvCOLOR_LAND_G, kvCOLOR_LAND_B);
        }
        
        // HORIZONTAL CROSSHAIR
        glBegin(GL_LINES);
        glVertex3f(-10.0f, kvLIMIT_CENTER_Y, -1.0f);
        glVertex3f( 10.0f, kvLIMIT_CENTER_Y, -1.0f);
        glEnd();
        // VERTICAL CROSSHAIR
        glBegin(GL_LINES);
        glVertex3f( kvLIMIT_CENTER_X, -10.0f, -1.0f);
        glVertex3f( kvLIMIT_CENTER_X, 10.0f, -1.0f);
        glEnd();
    }
    
    // UPDATE THE NODES
    xnWaitAndUpdateAll(kvCONTEXT_PTR);
    [self drawStickFigure:kvUSER_NODE_HANDLE depthNode:kvDEPTH_NODE_HANDLE depthMetaData:kvDEPTH_MD_PTR];
    
    glutSwapBuffers();
}

// function: orientMe:float
// description: corrects orientation of tracked user
- (void) orientMe:(float) theta
{
    static float x = 0.0f, y = 0.0f, z = 0.0f;
    static float lx = 0.0f, ly = 0.0f, lz = -1.0f; lx += sin(theta);
    //lz += -cos(ang);
    
    glLoadIdentity();
    
    gluLookAt(x, y, z,
              lx, ly, lz,
              0.0f, 1.0f, 0.0f);
}

//------------------------------------------------------------
// KARD KINECT INITIALIZER
//------------------------------------------------------------
// function: initTracking
// description: initializes the complete skeleon tracking part of KARD
- (BOOL) initTracking {
    XnStatus nRetVal = XN_STATUS_OK;
    XnNodeHandle hScriptNode;
    XnEnumerationErrors * pErrors = NULL;
    
    XnCallbackHandle hCalib;
    XnCallbackHandle hPose;
    
    XnCallbackHandle hCallBack;
    
    const char *fn = SAMPLE_XML_PATH;
    
    nRetVal = xnInitFromXmlFileEx(fn, &kvCONTEXT_PTR, pErrors, &hScriptNode);
    CHECK_RC(nRetVal, "InitFromXml");
    
    nRetVal = xnFindExistingRefNodeByType(kvCONTEXT_PTR, XN_NODE_TYPE_DEPTH, &kvDEPTH_NODE_HANDLE);
    CHECK_RC(nRetVal, "Find depth generator");
    
    kvDEPTH_MD_PTR = xnAllocateDepthMetaData();
    // try to get a user
    nRetVal = xnFindExistingRefNodeByType(kvCONTEXT_PTR, XN_NODE_TYPE_USER, &kvUSER_NODE_HANDLE);
    CHECK_RC(nRetVal, "Find user generator");
    
    // register callbacks
    nRetVal = xnRegisterUserCallbacks(kvUSER_NODE_HANDLE, kvNewUser, kvLostUser, NULL, &hCallBack);
    CHECK_RC(nRetVal, "Register User Callbacks");
    
    nRetVal = xnSetSkeletonProfile(kvUSER_NODE_HANDLE, XN_SKEL_PROFILE_ALL);
    CHECK_RC(nRetVal, "Setting Skeleton Profile");
    
    xnRegisterCalibrationCallbacks(kvUSER_NODE_HANDLE, kvCalibrationStart, kvCalibrationEnd, NULL, &hCalib);
    xnRegisterToPoseCallbacks(kvUSER_NODE_HANDLE, kvPoseDetected, NULL, NULL, &hPose);
    
    xnStartGeneratingAll(kvCONTEXT_PTR);

    return (BOOL)nRetVal;
}

//------------------------------------------------------------
// OPENGL DRAWING
//------------------------------------------------------------
// function: drawStickPoint()
// description: draws a stick 3D point given an XnPoint3D
- (void) drawStickPoint: (XnNodeHandle) hDepthNode
                  point: (XnPoint3D) point
{
    xnConvertRealWorldToProjective(hDepthNode, 1, &point, &point);
    
    float fX = ((point.X-320)/ 320);
    float fY = -((point.Y-240) /240);
    //float fU = fX + 0.5;
    //float fV = fY + 0.5;
    
    glVertex3f(fX, fY, 0.0f);
}

// function: kvDrawJoint
// description: draws the skeleton joint
- (void) drawJoint: (XnSkeletonJoint) joint
          userNode: (XnNodeHandle) hUserNode
         depthNode: (XnNodeHandle) hDepthNode
            userID: (XnUserID) user
{
    static int i = 0;
    
    XnSkeletonJointPosition p;
    XnPoint3D point;
    
    float X,Y;
    
    glPushMatrix();
    xnGetSkeletonJointPosition(hUserNode, user, joint, &p);
    //printf("%s failed: %d\n",xnGetStatusString(rc),joint);
    
    point=p.position;
    xnConvertRealWorldToProjective(hDepthNode, 1, &point, &point);
    //printf("%f , %f\n",point.X,point.Y);
    
    X = (point.X - 320) / 320;
    Y = -1 * (point.Y - 240) / 240;
    
    glPushMatrix();
    glTranslatef(X, Y, 0);
    
    if (joint == 1){
        glutSolidSphere(0.05f,20,20);
        //printf("head x:%f y:%f ",X,Y);
        //printf("x:%f y:%f z:%f \n",point.X,point.Y,point.Z);
        //centerY(Y);
        //deltaAngle=X;
    }
    
    glutSolidSphere(.05f,20,20);
    glPopMatrix();
    
    i++;
}

// function: drawSingleUser
// description: draws a user on the GL context
- (void) drawSingleUser: (XnNodeHandle) hUserNode
              depthNode: (XnNodeHandle) hDepthNode
                 userID: (XnUserID) user
{
    int count=0;
    XnSkeletonJoint joint;
    
    for (count = 1; count < 25; count++) {
        
        glColor3f( (count / 24.0f), (count / 48.0f), 1.0f);
        joint = [self getJoint: count];
        
        if(!xnIsJointAvailable(hUserNode, joint)) continue;
        [self drawJoint:joint userNode:hUserNode depthNode:hDepthNode userID:user];
    }
}

// function: drawStickLine
// description: draws a stick line on the GL context between 2 joints
- (void) drawStickLine: (XnNodeHandle) hUserNode
             depthNode: (XnNodeHandle) hDepthNode
                userID: (XnUserID) user
            firstJoint: (XnSkeletonJoint) joint1
             lastJoint: (XnSkeletonJoint) joint2
{
    XnSkeletonJointPosition pos1, pos2;
    xnGetSkeletonJointPosition(hUserNode, user, joint1, &pos1);
    xnGetSkeletonJointPosition(hUserNode, user, joint2, &pos2);
    
    if (pos1.fConfidence == 1 && pos2.fConfidence == 1) {
        glColor3f(1.0f,0.5f,0.3f);
    } else {
        glColor3f(0.5,0.5,0.5);
        
        if ((pos1.position.X == 0 && pos1.position.Y == 0 && pos1.position.Z == 0) ||
            (pos2.position.X == 0 && pos2.position.Y == 0 && pos2.position.Z == 0)) {
            return;
        }
    }

    [self drawStickPoint:hDepthNode point:pos1.position];
    [self drawStickPoint:hDepthNode point:pos2.position];
}

// function: drawBones
// description: draws the skeleton of a user
- (void) drawBones: (XnNodeHandle) hUserNode
         depthNode: (XnNodeHandle) hDepthNode
            userID: (XnUserID) user
{
    // load the matrix onto the stack
    glPushMatrix();
    // set the thickness of each line
    glLineWidth(3.0);
    
    // begin the line drawing context
    glBegin(GL_LINES);
    
    // Draw each joint connection
    // The XN_SKEL_LEFT_HAND is connected to the .... XN_SKEL_LEFT_ELBOW
    // The XN_SKEL_LEFT_ELBOW is connected to the ... XN_SKEL_LEFT_SHOULDER...
    
    // draw everything above the hip
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_HAND lastJoint:XN_SKEL_LEFT_ELBOW];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_ELBOW lastJoint:XN_SKEL_LEFT_SHOULDER];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_SHOULDER lastJoint:XN_SKEL_TORSO];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_SHOULDER lastJoint:XN_SKEL_RIGHT_SHOULDER];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_TORSO lastJoint:XN_SKEL_RIGHT_SHOULDER];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_RIGHT_SHOULDER lastJoint:XN_SKEL_RIGHT_ELBOW];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_RIGHT_ELBOW lastJoint:XN_SKEL_RIGHT_HAND];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_NECK lastJoint:XN_SKEL_HEAD];
    
    // draw the hip and torso
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_TORSO lastJoint:XN_SKEL_LEFT_HIP];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_TORSO lastJoint:XN_SKEL_RIGHT_HIP];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_HIP lastJoint:XN_SKEL_RIGHT_HIP];
    
    // draw the legs
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_HIP lastJoint:XN_SKEL_LEFT_KNEE];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_LEFT_KNEE lastJoint:XN_SKEL_LEFT_FOOT];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_RIGHT_HIP lastJoint:XN_SKEL_RIGHT_KNEE];
    [self drawStickLine:hUserNode depthNode:hDepthNode userID:user firstJoint:XN_SKEL_RIGHT_KNEE lastJoint:XN_SKEL_RIGHT_FOOT];
    
    // end the drawing process
    glEnd();
    
    // remove matrix off the stack
    glPopMatrix();
}

// function: drawStickFigure
// description: draws the stick figure of a user
- (void) drawStickFigure: (XnNodeHandle) hUserNode
               depthNode: (XnNodeHandle) hDepthNode
           depthMetaData: (XnDepthMetaData *) pDepthMD
{
    // store the depthMap
    xnGetDepthMetaData(hDepthNode, pDepthMD);
    //XnPoint3D corner = xnCreatePoint3D( dm.XRes(), dm.YRes(), dm.ZRes());
    XnFloat XRes, YRes, ZRes;
    
    // simple storage for using in the point function
    XRes = pDepthMD->pMap->Res.X;
    YRes = pDepthMD->pMap->Res.Y;
    ZRes = pDepthMD->nZRes;
    
    XnUserID users[10];
    XnUInt16 nUsers = 10;
    
    glPushMatrix();
    
    xnGetUsers(hUserNode, users, &nUsers);
    
    // loop through each user and draw if being tracked
    int i;
    for (i = 0; i < nUsers; ++i) {
        if (xnIsSkeletonTracking(hUserNode, users[i])) {
            [self drawSingleUser:hUserNode depthNode:hDepthNode userID:users[i]];
            [self drawSingleUser:hUserNode depthNode:hDepthNode userID:users[i]];
            
            if(kvDRAW_BONES) [self drawBones:hUserNode depthNode:hDepthNode userID:users[i]];
            [self handsLocationLogic:hUserNode depthNode:hDepthNode userID:users[i]];
        }
    }
    
    glPopMatrix();
}

// function: kvDrawBoundaries
// description: draws the boundaries around the skeleton when a pose is detected
- (void) drawBoundaries: (XnNodeHandle) hDepthNode
                   refL: (XnPoint3D) refL
                   refR: (XnPoint3D) refR
                   left: (XnPoint3D) Left
                  right: (XnPoint3D) Right
{
    // draw boundary box
    float zLDiff, zRDiff;
    
    // convert points
    xnConvertRealWorldToProjective(hDepthNode, 1, &refL, &refL);
    xnConvertRealWorldToProjective(hDepthNode, 1, &refR, &refR);
    xnConvertRealWorldToProjective(hDepthNode, 1, &Left, &Left);
    xnConvertRealWorldToProjective(hDepthNode, 1, &Right, &Right);
    
    zLDiff = refL.Z - Left.Z;
    zRDiff = refR.Z - Right.Z;
    glLineWidth(3.0);
    
    //---------------------------------------------
    // LEFT HAND
    //---------------------------------------------
    // TOP
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-270)/240, -1.0f);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    // RIGHT
    glBegin(GL_LINES);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-210)/240, -1.0f);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    // BOTTOM
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-200)/240, -1.0f);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-200)/240, -1.0f);
    glEnd();
    // LEFT
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-210)/240, -1.0f);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    
    //---------------------------------------------
    // RIGHT HAND
    //---------------------------------------------
    // TOP
    glBegin(GL_LINES);
    glVertex3f( (refR.X-345)/320,-1*(refR.Y-270)/240, -1.0f);
    glVertex3f( (refR.X-295)/320,-1*(refR.Y-270)/240, -1.0f);
    glEnd();
    // RIGHT
    glBegin(GL_LINES);
    glVertex3f( (refR.X-295)/320,-1*(refR.Y-210)/240, -1.0f);
    glVertex3f( (refR.X-295)/320,-1*(refR.Y-270)/240, -1.0f);
    glEnd();
    // BOTTOM
    glBegin(GL_LINES);
    glVertex3f( (refR.X-335)/320,-1*(refR.Y-210)/240, -1.0f);
    glVertex3f( (refR.X-305)/320,-1*(refR.Y-210)/240, -1.0f);
    glEnd();
    // LEFT
    glBegin(GL_LINES);
    glVertex3f( (refR.X-345)/320,-1*(refR.Y-210)/240, -1.0f);
    glVertex3f( (refR.X-345)/320,-1*(refR.Y-270)/240, -1.0f);
    glEnd();
    
    //---------------------------------------------
    // CROSSHAIR
    //---------------------------------------------
    // SPHERE
    glPushMatrix();
    glTranslatef(0, 0.8f,0);
    glutSolidSphere(.05f,40,100);
    glPopMatrix();
    // VERTICAL
    glBegin(GL_LINES);
    glVertex3f( 0,.9, -1.0f);
    glVertex3f( 0,.7, -1.0f);
    glEnd();
}

//------------------------------------------------------------
// LOOKUPS
//------------------------------------------------------------
// function: getJoint
// description: looks up an XnSkeleton joint given an integer
- (XnSkeletonJoint) getJoint: (int) joint {
    switch (joint){
        case 1 : return XN_SKEL_HEAD;
        case 2 : return XN_SKEL_NECK;
        case 3 : return XN_SKEL_TORSO;
        case 4 : return XN_SKEL_WAIST;
        case 5 : return XN_SKEL_LEFT_COLLAR;
        case 6 : return XN_SKEL_LEFT_SHOULDER;
        case 7 : return XN_SKEL_LEFT_ELBOW;
        case 8 : return XN_SKEL_LEFT_WRIST;
        case 9 : return XN_SKEL_LEFT_HAND;
        case 10: return XN_SKEL_LEFT_FINGERTIP;
        case 11: return XN_SKEL_RIGHT_COLLAR;
        case 12: return XN_SKEL_RIGHT_SHOULDER;
        case 13: return XN_SKEL_RIGHT_ELBOW;
        case 14: return XN_SKEL_RIGHT_WRIST;
        case 15: return XN_SKEL_RIGHT_HAND;
        case 16: return XN_SKEL_RIGHT_FINGERTIP;
        case 17: return XN_SKEL_LEFT_HIP;
        case 18: return XN_SKEL_LEFT_KNEE;
        case 19: return XN_SKEL_LEFT_ANKLE;
        case 20: return XN_SKEL_LEFT_FOOT;
        case 21: return XN_SKEL_RIGHT_HIP;
        case 22: return XN_SKEL_RIGHT_KNEE;
        case 23: return XN_SKEL_RIGHT_ANKLE;
        case 24: return XN_SKEL_RIGHT_FOOT;
        default: return XN_SKEL_HEAD; // default head case
    }
}

//------------------------------------------------------------
// OpenNI DELEGATES/CALLBACKS
//------------------------------------------------------------
// function: kvNewUser
// description: delegate for handling when a NewUser is detected and begins pose detection
void XN_CALLBACK_TYPE kvNewUser(XnNodeHandle hUserNode, XnUserID user, void* pCookie) {
    printf("VISION: New user identified: %d\n", user);
    xnStartPoseDetection(hUserNode, "Psi", user);
}

// function: kvLostUser
// description: delegate for handling when a User is lost
void XN_CALLBACK_TYPE kvLostUser(XnNodeHandle hUserNode, XnUserID user, void* pCookie) {
    printf("VISION: User %d lost\n", user);
}

// function: kvCalibrationStart
// description: starts calibration of the new user after detection
void XN_CALLBACK_TYPE kvCalibrationStart(XnNodeHandle hUserNode, XnUserID user, void* pCookie) {
    printf("VISION: Calibration started for user %d\n", user);
}

// function: kvCalibrationEnd
// description: checks if previous calibration was successful and begins skeleton tracking, otherwise restart
void XN_CALLBACK_TYPE kvCalibrationEnd(XnNodeHandle hUserNode, XnUserID user, XnBool bSuccess, void* pCookie) {
    printf("VISION: Calibration completed for user %d: %s\n", user, (bSuccess) ? "Success" : "Failure");
    
    // check if calibration worked otherwise restart the pose detection
    if (bSuccess) {
        // set the points
        xnStartSkeletonTracking(hUserNode, user);
    } else {
        xnStartPoseDetection(hUserNode, "Psi", user);
    }
}

// function: kvPoseDetected
// description: delegate for a registered pose detected and requests skeleton calibration and stops pose detection
void XN_CALLBACK_TYPE kvPoseDetected(XnNodeHandle hUserNode, const XnChar* pose, XnUserID user, void* pCookie) {
    printf("VISION: Pose '%s' detected for user %d\n", pose, user);
    xnRequestSkeletonCalibration(hUserNode, user, FALSE);
    xnStopPoseDetection(hUserNode, user);
}

//------------------------------------------------------------
// RUNNING EVENTS
//------------------------------------------------------------
// function: handsBodyMovementLogic
// description: handles the piloting logic
- (void) handsBodyMovementLogic: (XnNodeHandle) hDepthNode
                       leftHand: (XnPoint3D) LeftHand
                      rightHand: (XnPoint3D) RightHand
                           head: (XnPoint3D) Head
                          torso: (XnPoint3D) Torso
                   leftShoulder: (XnPoint3D) LeftShoulder
                  rightShoulder: (XnPoint3D) RightShoulder
{
    // our commands to be packaged
    int enable = 1;     // 0: hover             | 1: send commands
    float phi = 0;      // 0-1.0: bend forward  | -1.0-0: bend backwards
    float theta = 0;    // 0-1.0: strafe right  | -1.0-0: strafe left
    float gaz = 0;      // 0-1.0: ascend        | -1.0-0: descend
    float yaw = 0;      // 0-1.0: turn right    | -1.0-0: turn left
    float psi = 0.0;
    float psi_accuracy = 0.0;
    
    
    if(abs((int)(Torso.Z - kvORIGIN.Z)) > kvORIGIN_LIMIT_Z) {
        if(Torso.Z > kvORIGIN.Z) {
            printf("FORWARD\n");
            theta = 0.2;
        } else if (Torso.Z < kvORIGIN.Z ) {
            printf("BACKWARDS\n");
            theta = -0.2;
        }
    }
    
    if((abs((int)(LeftHand.Z - kvLHAND_ORIGIN.Z)) > 150) &&
       (abs((int)(RightHand.Z - kvRHAND_ORIGIN.Z)) > 150)) {
        if(LeftHand.Z < kvLHAND_ORIGIN.Z && RightHand.Z > kvRHAND_ORIGIN.Z) {
            printf("TURN RIGHT\n");
            yaw = 0.2;
        } else if (LeftHand.Z > kvLHAND_ORIGIN.Z && RightHand.Z < kvRHAND_ORIGIN.Z) {
            printf("TURN LEFT\n");
            yaw = -0.2;
        }
    }
    
    
    
    if((abs((int)(LeftShoulder.Y - LeftHand.Y)) < kvHOVER_LIMIT) &&
       abs((int)(RightShoulder.Y - RightHand.Y)) < kvHOVER_LIMIT ) {
        printf("HOVER\n");
        
        // send all 0's
    } else {
        // check elevation control
        if(LeftHand.Y < LeftShoulder.Y &&
           RightHand.Y < RightShoulder.Y) {
            printf("DESCEND\n");
            gaz = -0.2;
        } else if(LeftHand.Y > LeftShoulder.Y &&
                  RightHand.Y > RightShoulder.Y) {
            printf("ASCEND\n");
            gaz = 0.2;
        }
        
        // check tilt control
        //printf("Head: %f\n", headPoint.X);
        //printf("Torso: %f\n", torsoPoint.X);
        if(abs((int)(Head.X - Torso.X)) > 10) {
            if(Head.X < Torso.X) {
                printf("TILT LEFT\n");
                phi = -0.2;
            } else {
                printf("TILT RIGHT\n");
                phi = 0.2;
            }
        }
    }
    
    ardrone_tool_set_progressive_cmd(enable, phi, theta, gaz, yaw, psi, psi_accuracy);
}

// function: setJointPoint
// description: sets XnPoint3D given the XnSkeletonJoint
- (void) setJointPoint: (XnNodeHandle) hUserNode
                userID: (XnUserID) user
                 joint: (XnSkeletonJoint) joint
                 point: (XnPoint3D *) point
{
    XnSkeletonJointPosition skeletonPosition;
    xnGetSkeletonJointPosition(hUserNode, user, joint, &skeletonPosition);
    
    // set the inplace value
    *point = skeletonPosition.position;
}

// function: handsLocationLogic
// description: handles the hand motions
- (void) handsLocationLogic: (XnNodeHandle) hUserNode
                  depthNode: (XnNodeHandle) hDepthNode
                     userID: (XnUserID) user
{
    //-----!!!!! One thing to think about is that if we move forward or back that we might want to reset the initHands values could change...
    //static int timer=0;
    //static float r = 1.0f, g = 0.0f, b = 0.0f;
    
    //static XnPoint3D refLeftHand, refRightHand;
    static XnPoint3D leftHandPoint,
    rightHandPoint,
    headPoint,
    torsoPoint,
    hipPoint,
    leftShoulderPoint,
    rightShoulderPoint;
    
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_LEFT_HAND point:&leftHandPoint];
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_RIGHT_HAND point:&rightHandPoint];
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_TORSO point:&torsoPoint];
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_HEAD point:&headPoint];
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_LEFT_HIP point:&hipPoint];
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_LEFT_SHOULDER point:&leftShoulderPoint];
    [self setJointPoint:hUserNode userID:user joint:XN_SKEL_RIGHT_SHOULDER point:&rightShoulderPoint];
    
    // check state and handoff accordingly
    if(kvIS_FLYING) {
        if(leftHandPoint.Y < hipPoint.Y && rightHandPoint.Y < hipPoint.Y) {
            kvIS_FLYING = FALSE;
            ardrone_tool_set_ui_pad_start(0);
        } else {
            [self handsBodyMovementLogic:hDepthNode
                                leftHand:leftHandPoint
                               rightHand:rightHandPoint
                                    head:headPoint
                                   torso:torsoPoint
                            leftShoulder:leftShoulderPoint
                           rightShoulder:rightShoulderPoint];
        }
    } else {
        if( leftHandPoint.Y > headPoint.Y && rightHandPoint.Y > headPoint.Y) {
            AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
            
            printf("FLY\n");
            kvIS_FLYING = TRUE;
            
            // set the Z origin for reference
            kvORIGIN.Z = torsoPoint.Z;
            kvLHAND_ORIGIN.Z = leftHandPoint.Z;
            kvRHAND_ORIGIN.Z = rightHandPoint.Z;
            
            ardrone_tool_set_ui_pad_start(1);
        } else if( leftHandPoint.Y < hipPoint.Y && rightHandPoint.Y > headPoint.Y) {
            ardrone_tool_set_ui_pad_select(1);
            printf("EMERGENCY\n");
        }
    }
}

- (void)idle:(NSTimer*)timer
{
    [self setNeedsDisplay:YES];
}

- (void) update
{
    [self renderScene];
    NSTimer *updateTimer = [NSTimer timerWithTimeInterval:1.0f/30.0f target:self selector:@selector(idle:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
    glFlush();
}


- (void)drawRect:(NSRect)dirtyRect
{
    //[self initScene];
    //[self update];
}

@end
