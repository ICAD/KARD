SDK_PATH:=$(shell pwd)/../ARDrone/OSX/ARDroneLib
BUILD_OS_FLAG="USE_OSX=yes"
USE_OSX=yes
include $(SDK_PATH)/Soft/Build/custom.makefile
include $(SDK_PATH)/Soft/Build/config.makefile

SDK_FLAGS+="USE_APP=no"
SDK_FLAGS+="USE_LIB=yes"

all:
	@$(MAKE) -C $(SDK_PATH)/Soft/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) $(BUILD_OS_FLAG)
	@$(MAKE) -C $(SDK_PATH)/VP_SDK/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) $(BUILD_OS_FLAG)

#find $(SDK_PATH)/Soft/Build -type f -name "*.a" -exec cp "{}" ../Libraries/ \;