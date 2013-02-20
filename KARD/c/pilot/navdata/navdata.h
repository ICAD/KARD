//
//  navdata.h
//  KARD
//
//  Created by Tyler on 2012-10-15.
//  Copyright (c) 2012 ICAD. All rights reserved.
//

#ifndef KARD_navdata_h
#define KARD_navdata_h

#include "KARD-Prefix.pch"
#include <ardrone_tool/Navdata/ardrone_navdata_client.h>


/* Initialization local variables before event loop  */
C_RESULT navdata_client_init( void* data );

/* Receving navdata during the event loop */
C_RESULT navdata_client_process( const navdata_unpacked_t* const navdata );

/* Relinquish the local resources after the event loop exit */
C_RESULT navdata_client_release( void );

#endif
