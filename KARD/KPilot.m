//
//  KPilot.m
//  KARD
//
//  Created by Tyler on 2013-02-19.
//  Copyright (c) 2013 ICAD. All rights reserved.
//

#import "KPilot.h"


@implementation KPilot

pre_stage_cfg_t precfg;
display_stage_cfg_t dispCfg;

codec_type_t drone1Codec = P264_CODEC;
codec_type_t drone2Codec = H264_360P_CODEC;
ZAP_VIDEO_CHANNEL videoChannel = ZAP_CHANNEL_HORI;

#define FILENAMESIZE (256)
char encodedFileName[FILENAMESIZE] = {0};

int32_t exit_ihm_program = 1;

enum KARD_WINDOW_ENUM {
    KARD_WINDOW_WIDTH   = 640,
    KARD_WINDOW_HEIGHT  = 480,
    KARD_WINDOW_X       = 300,
    KARD_WINDOW_Y       = 100
};

void controlCHandler (int signal)
{
    // Flush all streams before terminating
    fflush (NULL);
    usleep (200000); // Wait 200 msec to be sure that flush occured
    printf ("\nAll files were flushed\n");
    exit (0);
}



void kdPrintText(float x, float y, float z, float r, float g, float b, float a, char * text) {
    glColor4f(r,g,b,a);
    glRasterPos3d(x,y,z);
    
    //glLoadIdentity();
    int limit = strlen(text);
    int counter = -1;
    
    while(counter++ <  limit - 1) {
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, text[counter]);
    }
    
}

void kpShowStatus() {
    float x = 0.1;
    float y = -0.05;
    static int counter = 0;
    
    char batteryStatusText[30];
    char heightStatusText[30];
    char psiStatusText[30];
    
    sprintf(batteryStatusText, "Battery: %d%%", counter++);
    sprintf(heightStatusText, "Height: %dm", counter++);
    sprintf(psiStatusText, "Psi: %d", counter++);
    
    kdPrintText(x, y-=0.15, 0, 1, 1, 1, 1, batteryStatusText);
    kdPrintText(x, y-=0.15, 0, 1, 1, 1, 1, heightStatusText);
    kdPrintText(x, y-=0.15, 0, 1, 1, 1, 1, psiStatusText);
}


- (void) kpInitPilot {
    
}

- (void) kpInitHUD:(int *)window {
    *window = glutCreateWindow("AR.Drone 2.0 | Status");
    //glutDisplayFunc(kpRenderHUD());
    glTranslatef(-1, 1, 0);
    
    [self kpInitPilot];
}

- (void) kpRenderHUD {
    // clear the GL buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    glClearColor(1, 1, 0.0f, 0.5f);
    glClearDepth(1.0f);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    
    kpShowStatus();
}

- (void) kpRenderVideo {
    
}

C_RESULT ardrone_tool_init_custom (void) {
    printf("STARTING AR.Drone Thread\n");
    /**
     * Set application default configuration
     *
     * In this example, we use the AR.FreeFlight configuration :
     * - Demo navdata rate (15Hz)
     * - Useful additionnal navdata packets enabled (detection, games, video record, wifi quality estimation ...)
     * - Adaptive video enabled (bitrate_ctrl_mode) -> video bitrate will change according to the available bandwidth
     */
    ardrone_application_default_config.navdata_demo = TRUE;
    ardrone_application_default_config.navdata_options = (NAVDATA_OPTION_MASK(NAVDATA_DEMO_TAG) | NAVDATA_OPTION_MASK(NAVDATA_VISION_DETECT_TAG) | NAVDATA_OPTION_MASK(NAVDATA_GAMES_TAG) | NAVDATA_OPTION_MASK(NAVDATA_MAGNETO_TAG) | NAVDATA_OPTION_MASK(NAVDATA_HDVIDEO_STREAM_TAG) | NAVDATA_OPTION_MASK(NAVDATA_WIFI_TAG));
    if (IS_ARDRONE2)
    {
        ardrone_application_default_config.video_codec = drone2Codec;
    }
    else
    {
        ardrone_application_default_config.video_codec = drone1Codec;
    }
    ardrone_application_default_config.video_channel = videoChannel;
    ardrone_application_default_config.bitrate_ctrl_mode = 1;
    
    /**
     * Define the number of video stages we'll add before/after decoding
     */
#define EXAMPLE_PRE_STAGES 1
#define EXAMPLE_POST_STAGES 1
    
    /**
     * Allocate useful structures :
     * - index counter
     * - thread param structure and its substructures
     */
    uint8_t stages_index = 0;
    
    specific_parameters_t *params = (specific_parameters_t *)vp_os_calloc (1, sizeof (specific_parameters_t));
    specific_stages_t *example_pre_stages = (specific_stages_t *)vp_os_calloc (1, sizeof (specific_stages_t));
    specific_stages_t *example_post_stages = (specific_stages_t *)vp_os_calloc (1, sizeof (specific_stages_t));
    vp_api_picture_t *in_picture = (vp_api_picture_t *)vp_os_calloc (1, sizeof (vp_api_picture_t));
    vp_api_picture_t *out_picture = (vp_api_picture_t *)vp_os_calloc (1, sizeof (vp_api_picture_t));
    
    /**
     * Fill the vp_api_pictures used for video decodig
     * --> out_picture->format is mandatory for AR.Drone 1 and 2. Other lines are only necessary for AR.Drone 1 video decoding
     */
    in_picture->width = 640; // Drone 1 only : Must be greater than the drone 1 picture size (320)
    in_picture->height = 360; // Drone 1 only : Must be greater that the drone 1 picture size (240)
    
    out_picture->framerate = 20; // Drone 1 only, must be equal to drone target FPS
	out_picture->format = PIX_FMT_RGB24;
	//out_picture->format = PIX_FMT_RGB565; // MANDATORY ! Only RGB24, RGB565 are supported
    out_picture->width = in_picture->width;
    out_picture->height = in_picture->height;
    
    // Alloc Y, CB, CR bufs according to target format
    uint32_t bpp = 0;
    switch (out_picture->format)
    {
        case PIX_FMT_RGB24:
            // One buffer, three bytes per pixel
            bpp = 3;
            out_picture->y_buf = vp_os_malloc ( out_picture->width * out_picture->height * bpp );
            out_picture->cr_buf = NULL;
            out_picture->cb_buf = NULL;
            out_picture->y_line_size = out_picture->width * bpp;
            out_picture->cb_line_size = 0;
            out_picture->cr_line_size = 0;
            break;
        case PIX_FMT_RGB565:
            // One buffer, two bytes per pixel
            bpp = 2;
            out_picture->y_buf = vp_os_malloc ( out_picture->width * out_picture->height * bpp );
            out_picture->cr_buf = NULL;
            out_picture->cb_buf = NULL;
            out_picture->y_line_size = out_picture->width * bpp;
            out_picture->cb_line_size = 0;
            out_picture->cr_line_size = 0;
            break;
        default:
            fprintf (stderr, "Wrong video format, must be either PIX_FMT_RGB565 or PIX_FMT_RGB24\n");
            exit (-1);
            break;
    }
    
    /**
     * Allocate the stage lists
     *
     * - "pre" stages are called before video decoding is done
     *  -> A pre stage get the encoded video frame (including PaVE header for AR.Drone 2 frames) as input
     *  -> A pre stage MUST NOT modify these data, and MUST pass it to the next stage
     * - Typical "pre" stage : Encoded video recording for AR.Drone 1 (recording for AR.Drone 2 is handled differently)
     *
     * - "post" stages are called after video decoding
     *  -> The first post stage will get the decoded video frame as its input
     *   --> Video frame format depend on out_picture->format value (RGB24 / RGB565)
     *  -> A post stage CAN modify the data, as ardrone_tool won't process it afterwards
     *  -> All following post stages will use the output of the previous stage as their inputs
     * - Typical "post" stage : Display the decoded frame
     */
    example_pre_stages->stages_list = (vp_api_io_stage_t *)vp_os_calloc (EXAMPLE_PRE_STAGES, sizeof (vp_api_io_stage_t));
    example_post_stages->stages_list = (vp_api_io_stage_t *)vp_os_calloc (EXAMPLE_POST_STAGES, sizeof (vp_api_io_stage_t));
    
    /**
     * Fill the PRE stage list
     * - name and type are debug infos only
     * - cfg is the pointer passed as "cfg" in all the stages calls
     * - funcs is the pointer to the stage functions
     */
    stages_index = 0;
    
    vp_os_memset (&precfg, 0, sizeof (pre_stage_cfg_t));
    strncpy (precfg.outputName, encodedFileName, 255);
    
#ifdef __linux
    example_pre_stages->stages_list[stages_index].name = "Encoded Dumper"; // Debug info
    example_post_stages->stages_list[stages_index].name = "Decoded display"; // Debug info
#endif
    
    example_pre_stages->stages_list[stages_index].type = VP_API_FILTER_DECODER; // Debug info
    example_pre_stages->stages_list[stages_index].cfg  = &precfg;
    example_pre_stages->stages_list[stages_index++].funcs  = pre_stage_funcs;
    
    example_pre_stages->length = stages_index;
    
    /**
     * Fill the POST stage list
     * - name and type are debug infos only
     * - cfg is the pointer passed as "cfg" in all the stages calls
     * - funcs is the pointer to the stage functions
     */
    stages_index = 0;
    
    vp_os_memset (&dispCfg, 0, sizeof (display_stage_cfg_t));
    dispCfg.bpp = bpp;
    dispCfg.decoder_info = in_picture;
    
    example_post_stages->stages_list[stages_index].type = VP_API_OUTPUT_SDL; // Debug info
    example_post_stages->stages_list[stages_index].cfg  = &dispCfg;
    example_post_stages->stages_list[stages_index++].funcs  = display_stage_funcs;
    
    example_post_stages->length = stages_index;
    
    /**
     * Fill thread params for the ardrone_tool video thread
     *  - in_pic / out_pic are reference to our in_picture / out_picture
     *  - pre/post stages lists are references to our stages lists
     *  - needSetPriority and priority are used to control the video thread priority
     *   -> if needSetPriority is set to 1, the thread will try to set its priority to "priority"
     *   -> if needSetPriority is set to 0, the thread will keep its default priority (best on PC)
     */
    params->in_pic = in_picture;
    params->out_pic = out_picture;
    params->pre_processing_stages_list  = example_pre_stages;
    params->post_processing_stages_list = example_post_stages;
    params->needSetPriority = 0;
    params->priority = 0;
    
    /**
     * Start the video thread (and the video recorder thread for AR.Drone 2)
     */
    START_THREAD(opengl, params);
    //START_THREAD(main_application_thread, params);
    START_THREAD(video_stage, params);
    video_stage_init();
    
    if (2 <= ARDRONE_VERSION ()) {
        START_THREAD (video_recorder, NULL);
        video_recorder_init ();
    }
    
    video_stage_resume_thread ();
    
	//START_THREAD(main_application_thread, NULL);
	//ardrone_tool_input_add( &input_controller );
    return C_OK;
}

C_RESULT ardrone_tool_shutdown_custom ()
{
    video_stage_resume_thread(); //Resume thread to kill it !
    JOIN_THREAD(video_stage);
    JOIN_THREAD(kinect);
    
    if (2 <= ARDRONE_VERSION ()) {
        video_recorder_resume_thread ();
        JOIN_THREAD (video_recorder);
    }
    
	//JOIN_THREAD(main_application_thread);
	//ardrone_tool_input_remove(&input_controller);
    return C_OK;
}

bool_t ardrone_tool_exit () {
    return exit_ihm_program == 0;
}

@end
