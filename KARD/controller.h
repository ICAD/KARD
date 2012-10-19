//
//  controller.h
//  KARD
//
//  Created by Tyler on 2012-10-15.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#ifndef KARD_controller_h
#define KARD_controller_h

#include "api.h"
#include "control.h"

C_RESULT open_controller(void);

C_RESULT update_controller(void);

C_RESULT close_controller(void);

input_device_t input_controller;

enum controller_input {
    ASCEND = 'i',
    DESCEND = 'k',
    ROTATE_RIGHT = 'l',
    ROTATE_LEFT = 'j',
    FORWARD = 'w',
    REVERSE = 's',
    STRAFE_LEFT = 'a',
    STRAFE_RIGHT = 'd',
    TAKE_OFF = '1',
    LAND = '2',
    EMERGENCY = '3'
};

#endif
