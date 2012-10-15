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

#endif
