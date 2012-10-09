#KARD: Kinect-A.R. Drone
The KARD Project is to allow the A.R. Drone to be controlled via the Kinect gestures.

#Getting the Environment Setup for Kinect & A.R. Drone

##Using Kinect and OpenNI/PrimeSense in Xcode (4.5)
Use the script *_install_mac_kinect.sh*
* Command line options:
	* "--devel": use the Unstable libraries
	* "uninstall": remove all OpenNI/PrimeSense/Kinect/libusb packages
	
##Using A.R. Drone with Xcode
To use the A.R. Drone SDK 2.0 with Xcode (4.5) do the following:

###Building the Libraries
_*Note:* We are using the Examples' libraries as it compiles a complete set of static libraries_
_More detailed instructions can be found in: ARDrone/README.textile_

###Clean and rebuild the libraries
	$> cd into ARDrone/
	$> cd Examples/OSX
	$> make USE\_OSX=yes clean
	$> make USE\_OSX=yes
	$> cd -

###Copy the libraries into _*'Libraries'*_ folder
	$> find . -name "lib*.a" -exec cp "{}" ../Libraries/ \;

###Add the Search Paths to your Xcode Build Settings
Search for "Search Paths" and enter the following in each row
1. Header Search Paths: $(SRCROOT)/ARDrone/ARDroneLib/**
2. Library Search Paths: $(SRCROOT)/Libraries

###Add the Static Libraries to your Xcode Build Phases
Under *_Link Binary With Libraries_*:
- Click the *"+"*
- Select *"Add Other"*
- Select the following libraries under *"Libraries"*:
	* libpc_ardrone.a
	* libsdk.a
	* libvlib.a