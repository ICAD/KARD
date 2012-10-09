#!/bin/sh

if [ "$1" == "uninstall" ]; then
	brew uninstall sensor-kinect
	brew uninstall openni
	brew uninstall nite
	brew uninstall libusb
	exit;
fi


cd /usr/local/Library/Formula
curl --insecure -O "https://raw.github.com/totakke/openni-formula/master/openni.rb"
curl --insecure -O "https://raw.github.com/totakke/openni-formula/master/sensor-kinect.rb"
curl --insecure -O "https://raw.github.com/totakke/openni-formula/master/nite.rb"

#install libusb for universal
brew install libusb --universal

#install openni
brew install openni "$1"

sudo mkdir -p /var/lib/ni
sudo niReg /usr/local/lib/libnimMockNodes.dylib
sudo niReg /usr/local/lib/libnimCodecs.dylib
sudo niReg /usr/local/lib/libnimRecorder.dylib

#install NITE
brew install nite  "$1"

sudo niReg /usr/local/lib/libXnVFeatures_1_5_2.dylib /usr/local/etc/primesense/Features_1_5_2
sudo niReg /usr/local/lib/libXnVHandGenerator_1_5_2.dylib /usr/local/etc/primesense/Hands_1_5_2
	
sudo niLicense PrimeSense 0KOIk2JeIBYClPWVnMoRKn5cdY4=

#install SensorKinect
brew install sensor-kinect  "$1"

sudo niReg /usr/local/lib/libXnDeviceSensorV2KM.dylib /usr/local/etc/primesense
sudo niReg /usr/local/lib/libXnDeviceFile.dylib /usr/local/etc/primesense

sudo mkdir -p /var/log/primesense/XnSensorServer
sudo chmod a+w /var/log/primesense/XnSensorServer 