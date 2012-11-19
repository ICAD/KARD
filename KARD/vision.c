//
//  vision.c
//============================================================
// INCLUDES
//============================================================
#include "api.h"
#include "vision.h"
#include <stdio.h>
#include <math.h>
#include <GL/glew.h>

#ifdef __APPLE__
    #include <OpenGL/gl.h>
    #include <GLUT/glut.h>
    #include <OpenGL/glext.h>
#elif __linux
    #include <GL/gl.h>
    #include <GL/glut.h>
    #include <GL/glext.h>
#endif

//============================================================
// GLOBALS
//============================================================
XnContext *         kvCONTEXT_PTR;
XnNodeHandle        kvUSER_NODE_HANDLE;
XnNodeHandle        kvDEPTH_NODE_HANDLE;
XnDepthMetaData *   kvDEPTH_MD_PTR;
XnBool              kvDRAW_BONES = TRUE;

//============================================================
// DEFINES
//============================================================
#ifdef __APPLE__
    #define SAMPLE_XML_PATH "SamplesConfig.xml"
#elif __linux
    #define SAMPLE_XML_PATH "../data/SamplesConfig.xml"
#endif

#define CHECK_RC(rc, what)	\
    if (rc != XN_STATUS_OK) { \
    printf("%s failed: %s\n", what, xnGetStatusString(rc));	\
    return rc;	}

//------------------------------------------------------------
// KEYPRESS SIMULATIONS
//------------------------------------------------------------
// function: kvKeyPress()
// description: delegate for GLUT Keydown
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
        case GLUT_KEY_DOWN :
            printf("VISION: KEYDOWN DOWN\n");
            break;
        case GLUT_KEY_F5:
            printf("VISION: KEYDOWN KEY");
            kvDRAW_BONES = !kvDRAW_BONES;
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

// function: kvSendKeyDown()
// TODO: CHECK IF THIS IS NEEDED
void kvSendKeyDown(char charCode) {
    //SendVKDown((unsigned short)VkKeyScanA(charCode));
    printf("SendKeyDown: %c\n", charCode);
    
    
}

// function: kvSendKeyUp()
// TODO: CHECK IF THIS IS NEEDED
void kvSendKeyUp(char charCode) {
    //SendVKUp((unsigned short)VkKeyScanA(charCode));
    printf("SendKeyUp: %c\n", charCode);
    

    switch(charCode) {
        case 'f':
            printf("TAKE-OFF\n");
            ardrone_tool_set_ui_pad_start(1);
            //ardrone_tool_set_ui_pad_select(1);
            break;
        case 'd':
            printf("LAND\n");
            ardrone_tool_set_ui_pad_start(0);
            break;
        default:
            printf("EMERGENCY\n");
            break;
    }
}

//------------------------------------------------------------
// OPENGL
//------------------------------------------------------------
// function: kvInitScene()
// description: initializes the GL Scene
void kvInitScene() {
    glEnable(GL_DEPTH_TEST);
}

// function: kvRenderScene
// description: renders the GL context
void kvRenderScene() {
    static float angle = 0.0f, deltaAngle = 0.0f;
    static float cx = 0.02f, cy = 0.0f;
    
    angle += deltaAngle;
    kvOrientMe(angle);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glColor3f(0.9f, 0.0f, 0.0f);
    
    glBegin(GL_QUADS);
    glVertex3f(-10.0f, (-1 * cy) + 0.01f, -1.0f);
    glVertex3f(-10.0f, (-1 * cy) - 0.01f, -1.0f);
    glVertex3f( 10.0f, (-1 * cy) - 0.01f, -1.0f);
    glVertex3f( 10.0f, (-1 * cy) + 0.01f, -1.0f);
    glEnd();
    
    glBegin(GL_QUADS);
    glVertex3f( (cx + 0.01f), -10.0f, -1.0f);
    glVertex3f( (cx - 0.01f), -10.0f, -1.0f);
    glVertex3f( (cx - 0.01f), 10.0f, -1.0f);
    glVertex3f( (cx + 0.01f), 10.0f, -1.0f);
    glEnd();
    
    xnWaitAndUpdateAll(kvCONTEXT_PTR);
    kvDrawStickFigure(kvUSER_NODE_HANDLE, kvDEPTH_NODE_HANDLE, kvDEPTH_MD_PTR);
    
    glutSwapBuffers();
}

// function: kvOrientMe()
// description: corrects orientation of tracked user
void kvOrientMe(float theta) {
    static float x = 0.0f, y = 0.0f, z = 0.0f;
    static float lx = 0.0f, ly = 0.0f, lz = -1.0f; lx += sin(theta);
    //lz += -cos(ang);
    
    glLoadIdentity();
    
    gluLookAt(x, y, z,
              lx, ly, lz,
              0.0f, 1.0f, 0.0f);
}

//------------------------------------------------------------
// KARD VISION INITIALIZER
//------------------------------------------------------------
// function: kvInitVision()
// description: initializes the complete vision part of KARD
XnStatus kvInitVision() {
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
    
	// fake init params
	int argc = 1;
	char *argv[] = { "KARD Vision", NULL };

    glutInit(&argc, argv);

    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
    glutInitWindowPosition(KARD_WINDOW_X, KARD_WINDOW_Y);
    glutInitWindowSize(KARD_WINDOW_HEIGHT, KARD_WINDOW_WIDTH);
    glutCreateWindow("KARD Skeleton Tracking");
    
    // Initialize the GL scene
    kvInitScene();
    
    glutIgnoreKeyRepeat(1);
    
    // set GLUT KEYPRESS delegates
    glutSpecialFunc(kvKeyPress);
    glutSpecialUpFunc(kvKeyRelease);
    
    glutDisplayFunc((void *)kvRenderScene);
    glutIdleFunc((void *)kvRenderScene);
    
    return nRetVal;
}

// function: kvStartVision()
// description: starts the OPENGL drawing loop
void kvStartVision() {
	glutMainLoop();
}

//------------------------------------------------------------
// OPENGL DRAWING
//------------------------------------------------------------
// function: kvDrawStickPoint()
// description: draws a stick 3D point given an XnPoint3D
void kvDrawStickPoint(XnNodeHandle hDepthNode, XnPoint3D point) {
    xnConvertRealWorldToProjective(hDepthNode, 1, &point, &point);
    
    float fX = ((point.X-320)/ 320);
    float fY = -((point.Y-240) /240);
    //float fU = fX + 0.5;
    //float fV = fY + 0.5;
    
    glVertex3f(fX, fY, 0.0f);
}

// function: kvDrawJoint
// description: draws the skeleton joint
void kvDrawJoint(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user, XnSkeletonJoint joint) {
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

// function: kvDrawSingleUser
// description: draws a user on the GL context
void kvDrawSingleUser(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user) {
    int count=0;
    XnSkeletonJoint joint;
    
    for (count = 1; count < 25; count++) {
        
        glColor3f( (count / 24.0f), (count / 48.0f), 1.0f);
        joint = kvGetJoint(count);
        
        if(!xnIsJointAvailable(hUserNode, joint)) continue;
        kvDrawJoint(hUserNode, hDepthNode, user, joint);
    }
}

// function: kvDrawStickLine
// description: draws a stick line on the GL context between 2 joints
void kvDrawStickLine(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user, XnSkeletonJoint joint1, XnSkeletonJoint joint2) {
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
    
    kvDrawStickPoint(hDepthNode, pos1.position);
    kvDrawStickPoint(hDepthNode, pos2.position);
}

// function: kvDrawBones
// description: draws the skeleton of a user
void kvDrawBones(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user) {
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
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_HAND, XN_SKEL_LEFT_ELBOW );
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_ELBOW, XN_SKEL_LEFT_SHOULDER);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_SHOULDER, XN_SKEL_TORSO);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_SHOULDER, XN_SKEL_RIGHT_SHOULDER);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_TORSO, XN_SKEL_RIGHT_SHOULDER);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_RIGHT_SHOULDER, XN_SKEL_RIGHT_ELBOW);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_RIGHT_ELBOW, XN_SKEL_RIGHT_HAND);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_NECK, XN_SKEL_HEAD);
    // draw the hip and torso
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_TORSO, XN_SKEL_LEFT_HIP);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_TORSO, XN_SKEL_RIGHT_HIP);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_HIP, XN_SKEL_RIGHT_HIP);
    // draw the legs
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_HIP, XN_SKEL_LEFT_KNEE);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_LEFT_KNEE, XN_SKEL_LEFT_FOOT);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_RIGHT_HIP, XN_SKEL_RIGHT_KNEE);
    kvDrawStickLine(hUserNode, hDepthNode, user, XN_SKEL_RIGHT_KNEE, XN_SKEL_RIGHT_FOOT);
    
    // end the drawing process
    glEnd();
    
    // remove matrix off the stack
    glPopMatrix();
}

// function: kvDrawStickFigure
// description: draws the stick figure of a user
void kvDrawStickFigure(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnDepthMetaData * pDepthMD) {
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
            kvDrawSingleUser(hUserNode, hDepthNode, users[i]);
            
            if(kvDRAW_BONES) kvDrawBones(hUserNode, hDepthNode, users[i]);
            kvHandsLocationLogic(hUserNode, hDepthNode, users[i]);
            
            /*mouse->Sendposition1(users[i],i,XN_SKEL_LEFT_SHOULDER,XN_SKEL_LEFT_ELBOW, XN_SKEL_LEFT_HAND,g_DepthGenerator,g_UserGenerator);
             mouse->Sendposition1(users[i],i,XN_SKEL_RIGHT_SHOULDER,XN_SKEL_RIGHT_ELBOW, XN_SKEL_RIGHT_HAND,g_DepthGenerator,g_UserGenerator);
             mouse->Sendposition(users[i],i,XN_SKEL_RIGHT_HAND,"RH",g_DepthGenerator,g_UserGenerator);
             mouse->Sendposition(users[i],i,XN_SKEL_LEFT_HAND,"LH",g_DepthGenerator,g_UserGenerator);*/
        }
    }
    
    glPopMatrix();
}

// function: kvDrawBoundaries
// description: draws the limits of the canvas
void kvDrawBoundaries (XnNodeHandle hDepthNode, XnPoint3D refL, XnPoint3D refR, XnPoint3D Left, XnPoint3D Right) {
    // draw boundary box
    float zLDiff,zRDiff;
    
    // convert points
    xnConvertRealWorldToProjective(hDepthNode, 1, &refL, &refL);
    xnConvertRealWorldToProjective(hDepthNode, 1, &refR, &refR);
    xnConvertRealWorldToProjective(hDepthNode, 1, &Left, &Left);
    xnConvertRealWorldToProjective(hDepthNode, 1, &Right, &Right);
    
    zLDiff = refL.Z - Left.Z;
    zRDiff = refR.Z - Right.Z;
    glLineWidth(3.0);
    
    //--Top Left HanD
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-200)/240, -1.0f);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-200)/240, -1.0f);
    glEnd();
    //--Bottom
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-270)/240, -1.0f);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    //--Left
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-210)/240, -1.0f);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    //--Right
    glBegin(GL_LINES);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-210)/240, -1.0f);
    glVertex3f( (refL.X-345)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    
    glBegin(GL_LINES);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-210)/240, -1.0f);
    glVertex3f( (refL.X-295)/320,-1*(refL.Y-270)/240, -1.0f);
    glEnd();
    //--RIght Hand Top
    glBegin(GL_LINES);
    glVertex3f( (refR.X-335)/320,-1*(refR.Y-210)/240, -1.0f);
    glVertex3f( (refR.X-305)/320,-1*(refR.Y-210)/240, -1.0f);
    glEnd();
    //--Bottom
    glBegin(GL_LINES);
    glVertex3f( (refR.X-345)/320,-1*(refR.Y-270)/240, -1.0f);
    glVertex3f( (refR.X-295)/320,-1*(refR.Y-270)/240, -1.0f);
    glEnd();
    //--Left
    glBegin(GL_LINES);
    glVertex3f( (refR.X-345)/320,-1*(refR.Y-210)/240, -1.0f);
    glVertex3f( (refR.X-345)/320,-1*(refR.Y-270)/240, -1.0f);
    glEnd();
    //--Right
    glBegin(GL_LINES);
    glVertex3f( (refR.X-295)/320,-1*(refR.Y-210)/240, -1.0f);
    glVertex3f( (refR.X-295)/320,-1*(refR.Y-270)/240, -1.0f);
    glEnd();
    
    
    glBegin(GL_LINES);
    glVertex3f( 0,.9, -1.0f);
    glVertex3f( 0,.7, -1.0f);
    glEnd();
    
    
    glPushMatrix();
    glTranslatef(0, 0.8f,0);
    glutSolidSphere(.025f,20,20);
    glPopMatrix();
}

//------------------------------------------------------------
// LOOKUPS
//------------------------------------------------------------
// function: kvGetJoint
// description: looks up an XnSkeleton joint given an integer
XnSkeletonJoint kvGetJoint(int a) {
    switch (a){
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
// DELEGATES/CALLBACKS
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
// function: kvHandsBodyMovementLogic
// description: handles keypresses based on skeleton pose
void kvHandsBodyMovementLogic(XnNodeHandle hDepthNode, XnPoint3D refL,XnPoint3D refR,XnPoint3D Left,XnPoint3D Right) {
    float xLDiff,xRDiff,zLDiff,zRDiff,yLDiff,yRDiff;
    XnPoint3D cL,cR,cLR,cRR; // change these!!! once testing is done
    
    xnConvertRealWorldToProjective(hDepthNode, 1, &refL, &cLR);
    xnConvertRealWorldToProjective(hDepthNode, 1, &refR, &cRR);
    xnConvertRealWorldToProjective(hDepthNode, 1, &Left, &cL);
    xnConvertRealWorldToProjective(hDepthNode, 1, &Right, &cR);
    //printf("RL: %f L: %f \n RR: %f R: %f\n",cLR.Z,cL.Z,cRR.Z,cR.Z);
    
    xLDiff=cLR.X-cL.X;
    xRDiff=cRR.X-cR.X;
    zLDiff=cLR.Z-cL.Z;
    zRDiff=cRR.Z-cR.Z;
    yLDiff=cLR.Y-cL.Y;
    yRDiff=cRR.Y-cR.Y;
    
    
    if (xLDiff>20 && xRDiff<-20) {
        kvSendKeyDown('w');
        kvSendKeyUp('w');
    } else if (xLDiff<-20 && xRDiff>20) {
        kvSendKeyDown('s');
        kvSendKeyUp('s');
    }
    
    if (zLDiff>100 ) {
        kvSendKeyUp('d');
        kvSendKeyDown('a');
    } else if (zRDiff>100 ) {
        kvSendKeyUp('a');
        kvSendKeyDown('d');
    } else {
        kvSendKeyUp('a');
        kvSendKeyUp('d');
    }
    
    if (yLDiff>20 && yRDiff>20 ) {
        //SendVKDown(VK_PRIOR);
        //SendVKUp(VK_NEXT);
        printf("up\n");
    } else if (yRDiff<-20 && yLDiff<-20) {
        printf("Down\n");
        //SendVKDown(VK_NEXT);
        //SendVKUp(VK_PRIOR);
    } else{
        //SendVKUp(VK_PRIOR);
        //SendVKUp(VK_NEXT);
    }
}

// function: kvSetJointPoint
// description: sets XnPoint3D given the XnSkeletonJoint
void kvSetJointPoint(XnNodeHandle hUserNode, XnUserID user, XnSkeletonJoint joint, XnPoint3D * point) {
    XnSkeletonJointPosition skeletonPosition;
    xnGetSkeletonJointPosition(hUserNode, user, joint, &skeletonPosition);
    
    // set the inplace value
    *point = skeletonPosition.position;
}

// function: kvHandsLocationLogic
// description: handles the hand motions
void kvHandsLocationLogic(XnNodeHandle hUserNode, XnNodeHandle hDepthNode, XnUserID user) {
    //-----!!!!! One thing to think about is that if we move forward or back that we might want to reset the initHands values could change...
    static int count=0;
    static XnBool flyPressed = FALSE;
    static XnBool initHands = FALSE;
    static XnBool steady = FALSE;
    static float r = 1.0f, g = 0.0f, b = 0.0f;
    
    //printf("FLY PRESSED: %s\n", ((flyPressed) ? "YES" : "NO"));
    
    static XnPoint3D refLeftHand,refRightHand;
    XnPoint3D lPoint,rPoint,head,torso;
    
    kvSetJointPoint(hUserNode, user, XN_SKEL_LEFT_HAND, &lPoint);
    kvSetJointPoint(hUserNode, user, XN_SKEL_RIGHT_HAND, &rPoint);
    kvSetJointPoint(hUserNode, user, XN_SKEL_HEAD, &head);
    kvSetJointPoint(hUserNode, user, XN_SKEL_TORSO, &torso);
    
    if (lPoint.Y > (torso.Y - 50) &&
        lPoint.Y < (head.Y + 10) &&
        rPoint.Y > (torso.Y - 50) &&
        rPoint.Y < (head.Y + 10)) {
        //This has been modded from original design to only look for both hands in position
        if (!steady) {
            if (++count > 8) {
                steady = TRUE;
                count = 0;
            }
        } else {
            //***-- it is now steady; check to see if this is first time through set ref hand points think about using states in the class for this//
            if (!initHands) {
                refLeftHand = lPoint;
                refRightHand = rPoint;
                initHands = TRUE;
            }
            
            r = 0;
            b = 1.0f;
            g = 0.0f;
            
            
            // FIX
            kvHandsBodyMovementLogic(hDepthNode, refLeftHand, refRightHand, lPoint, rPoint);
            kvDrawBoundaries(hDepthNode, refLeftHand, refRightHand, lPoint, rPoint);
        }
        
        flyPressed = FALSE;
    } else if (lPoint.Y > (head.Y + 20) && rPoint.Y > (head.Y + 20)) {
        // Checks if both hands are above head if so switch on flying
        if (!flyPressed) {
            g = 1.0f;
            b = 1.0f;
            r = 0.0f;
            
            steady = FALSE;
            count = 0;
            initHands = FALSE;
            flyPressed = TRUE;
            
            printf("FLY\n");
            
            kvSendKeyDown('f');
            kvSendKeyUp('f');
            
            
        }
    } else {
        /*
         We also reset the values of false and steady as well as initHands,
         again a states could probably increase readability as well as redundancy.
         Also need to make sure that the up down and left right buttons are sent back up
         */
        steady = FALSE;
        count = 0;
        initHands = FALSE;
        flyPressed = FALSE;
        //SendVKUp(VK_PRIOR);
        //SendVKUp(VK_NEXT);
        kvSendKeyUp('a');
        kvSendKeyUp('d');
    }
}