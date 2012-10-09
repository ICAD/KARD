h1. KARD: Kinect-A.R. Drone
The KARD Project is to allow the A.R. Drone to be controlled via the Kinect gestures.

h1. Getting the Environment Setup for Kinect & A.R. Drone

h2. Using Kinect and OpenNI/PrimeSense in Xcode (4.5)
Use the script *_install_mac_kinect.sh*
* Command line options:
	* "--devel": use the Unstable libraries
	* "uninstall": remove all OpenNI/PrimeSense/Kinect/libusb packages
	
h2. Using A.R. Drone with Xcode
To use the A.R. Drone SDK 2.0 with Xcode (4.5) do the following:

h3. Building the Libraries
_*Note:* We are using the Examples' libraries as it compiles a complete set of static libraries_
_Libraries were added from: https://github.com/mikehamer/ARDrone\_SDK\_2\_0\_OSX_
_More detailed instructions can be found in: ARDrone/README.textile_

h3. Clean and rebuild the libraries
#> cd into ARDrone/
#> cd Examples/OSX
#> make USE\_OSX=yes clean
#> make USE\_OSX=yes
#> cd -

h3. Copy the libraries into _*'Libraries'*_ folder
#> find . -name "lib*.a" -exec cp "{}" ../Libraries/ \;

h3. Add the Search Paths to your Xcode Build Settings
Search for "Search Paths" and enter the following in each row
1. Header Search Paths: $(SRCROOT)/ARDrone/ARDroneLib/**
2. Library Search Paths: $(SRCROOT)/Libraries

h3. Add the Static Libraries to your Xcode Build Phases
Under *_Link Binary With Libraries_*:
	1. Click the *"+"*
	2. Select *"Add Other"*
	3. Select the following libraries under *"Libraries"*:
		* libpc_ardrone.a
		* libsdk.a
		* libvlib.a