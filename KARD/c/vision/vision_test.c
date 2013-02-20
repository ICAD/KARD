#include "vision.h"

int main (int argc, char ** argv) {
	XnStatus kvStatus = kvInitVision();
	if(kvStatus == XN_STATUS_OK) {
		kvStartVision();
	} else {
		printf("Problem starting Kinect Vision\n");
	}
	

	return 0;
}
