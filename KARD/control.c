//
//  threads.c
//  KARD
//
//  Created by Tyler on 2012-10-10.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#include "control.h"

int32_t exit_ihm_program = 1;

/*------------------------------------------------------
 ARDRONE CONTROLS
 ------------------------------------------------------*/
/* The delegate object calls this method during initialization of an ARDrone application */
C_RESULT ardrone_tool_init_custom(void) {
    /* Registering for a new device of game controller */
    //ardrone_tool_input_add( &gamepad );
    
    /* Start all threads of your application */
    //START_THREAD( video_stage, NULL );
    START_THREAD( main_application_thread , NULL );
    return C_OK;
}


/* The delegate object calls this method when the event loop exit */
C_RESULT ardrone_tool_shutdown_custom(void) {
    /* Relinquish all threads of your application */
    //JOIN_THREAD( video_stage );
    
    /* Unregistering for the current device */
    //ardrone_tool_input_remove( &gamepad );
    JOIN_THREAD(main_application_thread);
    return C_OK;
}

/* The event loop calls this method for the exit condition */
bool_t ardrone_tool_exit() {
    return exit_ihm_program == 0;
}

C_RESULT signal_exit() {
    exit_ihm_program = 0;
    
    return C_OK;
}


/*------------------------------------------------------
 KARD'S ROUTINES
 ------------------------------------------------------*/
DEFINE_THREAD_ROUTINE(main_application_thread, data) {
    int input;
    
    //ardrone_at_set_progress_cmd_with_magneto()
    //ardrone_at_configuration_set_flying_mode(ARDRONE_MAGNETO_CMD_ENABLE, NULL, NULL, NULL);
    
    initscr();              // initialize the curses screen
    noecho();               // don't repeat our inputs
    cbreak();               // no buffer
    keypad(stdscr, TRUE);   // assign keyboard
    
    // our commands to be packaged
    int enable = 0;     // 0: hover             | 1: send commands
    float phi = 0;      // 0-1.0: bend forward  | -1.0-0: bend backwards
    float theta = 0;    // 0-1.0: strafe right  | -1.0-0: strafe left
    float gaz = 0;      // 0-1.0: ascend        | -1.0-0: descend
    float yaw = 0;      // 0-1.0: turn right    | -1.0-0: turn left
    
    do {
        //sleep(ARDRONE_REFRESH_MS);
        
        input = getch();
        
        //printf( "You pressed %c(%d)\n", input, input );
        // RESET OUR STUFF
        //ardrone_tool_set_ui_pad_ah(0); // UP
        //ardrone_tool_set_ui_pad_ab(0); // DOWN
        //ardrone_tool_set_ui_pad_l1(0); // LEFT
        //ardrone_tool_set_ui_pad_l2(0); // RIGHT
        
        
        //reset the values
        enable = 1;
        
        phi = theta = gaz = yaw = 0;
        
        switch(input) {
            case '1':
                printf("Take Off\n");
                ardrone_tool_set_ui_pad_start(1);
                break;
            case '2':
                printf("Land\n");
                ardrone_tool_set_ui_pad_start(0);
                break;
            case '3':
                printf("Emergency\n");
                ardrone_tool_set_ui_pad_select(1);
                break;
            case 'w':
                // forward
                printf("FORWARD\n");
                //TODO: NEED REVIEW
                //ardrone_tool_set_ui_pad_xy(1, 0);
                theta = 1;
                break;
            case 's':
                // back
                printf("BACK\n");
                //TODO: NEED REVIEW
                //ardrone_tool_set_ui_pad_xy(-1,0);
                theta = -1;
                break;
            case 'a':
                // left
                printf("LEFT\n");
                //ardrone_tool_set_ui_pad_l1(1);
                phi = -1;
                break;
            case 'd':
                // right
                printf("RIGHT\n");
                //ardrone_tool_set_ui_pad_l2(1); // RIGHT
                phi = 1;
                break;
            case 'i':
                // ascend
                printf("ASCEND\n");
                //ardrone_tool_set_ui_pad_ah(1);
                gaz = 1;
                break;
            case 'j':
                // descend
                printf("DESCEND\n");
                //ardrone_tool_set_ui_pad_ab(1);
                gaz = -1;
                break;
            case 'k':
                // rotate left
                printf("ROTATE LEFT\n");
                //ardrone_tool_set_ui_pad_
                yaw = -1;
                break;
            case 'l':
                // rotate right
                printf("ROTATE RIGHT\n");
                yaw = 1;
                break;
            default:
                printf("Default\n");
                //enable = 0;
                break;
        }
        
        //send the commands
        ardrone_tool_set_progressive_cmd(enable, phi, theta, gaz, yaw, 0.0, 0.0);
        
        refresh();
    } while( 0);
    
    endwin();
    
    printf("ENDED LOOP");
    return C_OK;
}



/* Implementing thread table in which you add routines of your application and those provided by the SDK */
BEGIN_THREAD_TABLE
    THREAD_TABLE_ENTRY( main_application_thread, 20 )
    THREAD_TABLE_ENTRY( ardrone_control, 20 )
    THREAD_TABLE_ENTRY( navdata_update, 20 )
    THREAD_TABLE_ENTRY( video_stage, 20 )
END_THREAD_TABLE