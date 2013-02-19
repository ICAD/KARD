#!/bin/sh

cd ../ARDrone/Examples/OSX
make USE_OSX=yes clean
make USE_OSX=yes
cd -

rm -rf ../Libraries
mkdir ../Libraries
find ../ARDrone/ARDroneLib/Soft/Build -type f -name "*.a" -exec cp "{}" ../Libraries/ \;