#KARD: Kinect-A.R. Drone
The KARD Project (Drone C&C - Command & Control) is designed to allow the user to pilot the AR.Drone 2.0 using either the XBOX Kinect or the Wiimote on a Mac.

##SDK Requirements
* OpenNI
* OpenCV
* AR.Drone

Note: This has been tested on 10.7 and 10.8 using Xcode 4.6 (4H127).

***
#Building the Xcode Project
This is fairly straight forward. If all the above requirements are there just open up the KARD.xcodeproj, build and fly the drone. Otherwise, go to the <a href="#gettingSetup">setup steps</a>. 

#Running
The application is fairly simple. Once built and running in Xcode, it will initially look for a wiimote. If you opt to pilot using the Kinect select the "Kinect" tab and click "Start Tracking" to begin piloting using your body.

***
#<a id="gettingSetup">Getting the Environment Setup for Kinect & A.R. Drone</a>

##Using Kinect and OpenNI/PrimeSense in Xcode
Use the script *_install_mac_kinect.sh* located in the  *Tools* folder
* Command line options:
	* "--devel": use the Unstable libraries
	* "uninstall": remove all OpenNI/PrimeSense/Kinect/libusb packages

##Using A.R. Drone with Xcode
We are currently referencing Mike Hamer's workaround for the Drone's SDK to be used on Mac:
	https://github.com/mikehamer/ARDrone_SDK_2_0_OSX/tree/a49356610b1b72c872e4432cff52ac868faa8bfd

To use the A.R. Drone SDK 2.0 with Xcode do the following:

###Building the Libraries
_*Note:* We are using the Examples build as it compiles a complete set of static libraries we will be using_

_More detailed instructions can be found in: ARDrone/README.textile_

###Install OpenCV
OpenCV will be used for video and other image processing work. Although, there are private OpenCV.frameworks available we will be usin this instead. To install it, we are using brew:
	$> brew install opencv

###Clean and rebuild the libraries
This script will clean the build files for ARDrone and copy the static libraries into the _Libraries_ folder.
	$> cd into Tools/
	$> sh build_libs.sh

###Add the Search Paths to your Xcode Build Settings
Search for "Search Paths" and enter the following in each row
- Header Search Paths: $(SRCROOT)/ARDrone/ARDroneLib/**
- Library Search Paths: $(SRCROOT)/Libraries

###Add the Libraries/Frameworks to your Xcode Build Phases
Under *_Link Binary With Libraries_*:
- Click the *"+"*
- Select *"Add Other"*
- Select the following Frameworks:
	* GLKit.framework
- Select the following libraries under *"Libraries"*:
	* libpc_ardrone.a
	* libsdk.a
	* libvlib.a
- Select the following libraries under *"/usr/local/Cellar/lib"*:
	* libavcodec.a
	* libswscale.a
	* libavutil.a
	
#LICENSE
Copyright (C) 2013 Tyler Pham, Raymond Padillo and Many Ayromlou of Ryerson University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

This program also makes use of the Parrot AR.Drone library and the LICENSE can be found in those folders