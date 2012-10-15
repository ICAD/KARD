//
//  navdata.c
//  KARD
//
//  Created by Tyler on 2012-10-15.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#include "navdata.h"
/*------------------------------------------------------
 NAVDATA
 ------------------------------------------------------*/
/* Initialization local variables before event loop  */
C_RESULT demo_navdata_client_init( void* data ) {
    return C_OK;
}

/* Receving navdata during the event loop */
C_RESULT demo_navdata_client_process( const navdata_unpacked_t* const navdata ) {
	const navdata_demo_t*nd = &navdata->navdata_demo;
    
	printf("=====================\nNavdata for flight demonstrations =====================\n\n");
    
	printf("Control state : %i\n",nd->ctrl_state);
    printf("Battery level : %i mV\n",nd->vbat_flying_percentage);
	printf("Orientation   : [Theta] %4.3f  [Phi] %4.3f  [Psi] %4.3f\n",nd->theta,nd->phi,nd->psi);
	printf("Altitude      : %i\n",nd->altitude);
	printf("Speed         : [vX] %4.3f  [vY] %4.3f  [vZPsi] %4.3f\n",nd->theta,nd->phi,nd->psi);
    
    return C_OK;
}

/* Relinquish the local resources after the event loop exit */
C_RESULT demo_navdata_client_release( void ) {
    return C_OK;
}