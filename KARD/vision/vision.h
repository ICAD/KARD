//
// vision.h
//
// NOTES: 'kv' is used a prefix for KARD Vision to separate
// functional references from 'kp' which is KARD Pilot
//============================================================
// INCLUDES
//============================================================
#include "api.h"
#include <XnOpenNI.h>

//============================================================
// Prototypes
//============================================================
//------------------------------------------------------------
// KEYPRESS SIMULATIONS
//------------------------------------------------------------
// function: kvKeyPress()
// description: delegate for GLUT Keydown
void kvKeyPress(int key, int x, int y);

// function: kvKeyRelease()
// description: delegate for GLUT Keyup
void kvKeyRelease(int key, int x, int y);

//------------------------------------------------------------
// KARD VISION INITIALIZER
//------------------------------------------------------------
// function: kvInitVision()
// description: initializes the complete vision part of KARD
XnStatus kvInitVision();

// function: kvStartVision()
// description: starts the OPENGL drawing loop
void kvStartVision();

//------------------------------------------------------------
// OPENGL
//------------------------------------------------------------
// function: kvInitScene()
// description: initializes the GL Scene
void kvInitScene();

// function: kvRenderScene
// description: renders the GL context
void kvRenderScene();

// function: kvOrientMe()
// description: corrects orientation of tracked user
void kvOrientMe(float theta);

//------------------------------------------------------------
// OPENGL DRAWING
//------------------------------------------------------------
// function: kvDrawStickPoint()
// description: draws a stick 3D point given an XnPoint3D
void kvDrawStickPoint(XnNodeHandle hDepthNode, XnPoint3D point);

// function: kvDrawJoint
// description: draws the skeleton joint
void kvDrawJoint(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user, XnSkeletonJoint joint);

// function: kvDrawSingleUser
// description: draws a user on the GL context
void kvDrawSingleUser(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user);

// function: kvDrawStickLine
// description: draws a stick line on the GL context between 2 joints
void kvDrawStickLine(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user, XnSkeletonJoint joint1, XnSkeletonJoint joint2);

// function: kvDrawBones
// description: draws the skeleton of a user
void kvDrawBones(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user);

// function: kvDrawStickFigure
// description: draws the stick figure of a user
void kvDrawStickFigure(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnDepthMetaData * pDepthMD) ;

// function: kvDrawBoundaries
// description: draws the boundaries around the skeleton when a pose is detected
void kvDrawBoundaries (XnNodeHandle hDepthNode, XnPoint3D refL, XnPoint3D refR, XnPoint3D Left, XnPoint3D Right);

//------------------------------------------------------------
// LOOKUPS
//------------------------------------------------------------
// function: kvGetJoint
// description: looks up an XnSkeleton joint given an integer
XnSkeletonJoint kvGetJoint(int a);

//------------------------------------------------------------
// DELEGATES/CALLBACKS
//------------------------------------------------------------
// function: kvNewUser
// description: delegate for handling when a NewUser is detected and begins pose detection
void XN_CALLBACK_TYPE kvNewUser(XnNodeHandle hUserNode, XnUserID user, void* pCookie);

// function: kvLostUser
// description: delegate for handling when a User is lost
void XN_CALLBACK_TYPE kvLostUser(XnNodeHandle hUserNode, XnUserID user, void* pCookie);

// function: kvCalibrationStart
// description: starts calibration of the new user after detection
void XN_CALLBACK_TYPE kvCalibrationStart(XnNodeHandle hUserNode, XnUserID user, void* pCookie);

// function: kvCalibrationEnd
// description: checks if previous calibration was successful and begins skeleton tracking, otherwise restart
void XN_CALLBACK_TYPE kvCalibrationEnd(XnNodeHandle hUserNode, XnUserID user, XnBool bSuccess, void* pCookie);

// function: kvPoseDetected
// description: delegate for a registered pose detected and requests skeleton calibration and stops pose detection
void XN_CALLBACK_TYPE kvPoseDetected(XnNodeHandle hUserNode, const XnChar* pose, XnUserID user, void* pCookie);

//------------------------------------------------------------
// RUNNING EVENTS
//------------------------------------------------------------
// function: kvHandsBodyMovementLogic
// description: handles the piloting logic
void kvHandsBodyMovementLogic(XnNodeHandle hDepthNode, XnPoint3D refL,XnPoint3D refR,XnPoint3D Left,XnPoint3D Right);

// function: kvSetJointPoint
// description: sets XnPoint3D given the XnSkeletonJoint
void kvSetJointPoint(XnNodeHandle hUserNode, XnUserID user, XnSkeletonJoint joint, XnPoint3D * point);

// function: kvHandsLocationLogic
// description: handles the hand motions
void kvHandsLocationLogic(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user);
