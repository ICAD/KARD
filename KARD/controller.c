//
//  controller.c
//  KARD
//
//  Created by Tyler on 2012-10-15.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#include "controller.h"

input_device_t input_controller = {
    "Controller",
    open_controller,
    update_controller,
    close_controller
};

C_RESULT open_controller(void) {
    
    
    initscr();              // initialize the curses screen
    noecho();               // don't repeat our inputs
    cbreak();               // no buffer
    keypad(stdscr, TRUE);   // assign keyboard
    
    return C_OK;
}

C_RESULT update_controller(void) {
    int input;
    
    //ardrone_at_set_progress_cmd_with_magneto()
    //ardrone_at_configuration_set_flying_mode(ARDRONE_MAGNETO_CMD_ENABLE, NULL, NULL, NULL);
    
    // our commands to be packaged
    int enable = 0;     // 0: hover             | 1: send commands
    float phi = 0;      // 0-1.0: bend forward  | -1.0-0: bend backwards
    float theta = 0;    // 0-1.0: strafe right  | -1.0-0: strafe left
    float gaz = 0;      // 0-1.0: ascend        | -1.0-0: descend
    float yaw = 0;      // 0-1.0: turn right    | -1.0-0: turn left
    input_state_t* input_state;
    
    input_state = ardrone_tool_input_get_state();
    
    input = getch();
    
    printf( "You pressed %c(%d)\n", input, input );
    // RESET OUR STUFF
    //ardrone_tool_set_ui_pad_ah(0); // UP
    //ardrone_tool_set_ui_pad_ab(0); // DOWN
    //ardrone_tool_set_ui_pad_l1(0); // LEFT
    //ardrone_tool_set_ui_pad_l2(0); // RIGHT
    
    
    //reset the values
    enable = 1;
    
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
            enable = 0;
            break;
    }
    //send the commands
    
    printf("\nCurrent state: %i\n", input_state->pcmd.flag);
    if(input != '1' || input != '2' || input != '3') {
        //ardrone_tool_set_progressive_cmd(enable, phi, theta, gaz, yaw, 0.0, 0.0);
    }
    refresh();
    
    return C_OK;
}

C_RESULT close_controller(void) {
    
    endwin();
    return C_OK;
}
