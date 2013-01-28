#####################################################
#	KARD Makefile
#####################################################
SDK_PATH:=$(shell pwd)/../ARDrone/Linux/ARDroneLib
PC_TARGET=yes
USE_LINUX=yes

ifdef MYKONOS
   include $(ARDRONE_CUSTOM_CONFIG)
   include $(ARDRONE_BUILD_CONFIG)
else
   include $(SDK_PATH)/Soft/Build/custom.makefile
   include $(SDK_PATH)/Soft/Build/config.makefile
endif

ifeq "$(RELEASE_BUILD)" "yes"
   ARDRONE_TARGET_DIR=$(shell pwd)
else
   ARDRONE_TARGET_DIR=$(shell pwd)
endif

TARGET=kard

SRC_DIR:=$(shell pwd)
OPENNI_INCLUDE=/usr/include/ni/
OPENNI_LIBS=-lOpenNI
OPENCV_CFLAGS=`pkg-config --cflags opencv`
OPENCV_LIBS=`pkg-config --libs opencv`
OPENGL_LIBS=`pkg-config --libs glu glew`
FREEGLUT_LIBS=-lglut

# Define application source files
GENERIC_BINARIES_SOURCE_DIR:=$(SRC_DIR)

GENERIC_BINARIES_COMMON_SOURCE_FILES+=			\
	navdata/navdata.c    \
	pilot/pilot.c  \
	pilot/video/display_stage.c \
	pilot/video/pre_stage.c \
	pilot/video/post_stage.c \
	vision/vision.c

GENERIC_INCLUDES+=					\
	$(SRC_DIR) \
	$(LIB_DIR) \
	$(SDK_PATH)/Soft/Common \
	$(SDK_PATH)/Soft/Lib \
	$(OPENNI_INCLUDE)

GENERIC_TARGET_BINARIES_PREFIX=

GENERIC_TARGET_BINARIES_DIR=$(ARDRONE_TARGET_DIR)


GENERIC_BINARIES_SOURCE_ENTRYPOINTS+=			\
   kard.c

GENERIC_INCLUDES:=$(addprefix -I,$(GENERIC_INCLUDES))

GENERIC_LIB_PATHS=-L$(GENERIC_TARGET_BINARIES_DIR) \
	$(OPENCV_CFLAGS)

GENERIC_LIBS=-lpc_ardrone -lrt -lm $(OPENCV_LIBS) $(OPENNI_LIBS) $(OPENGL_LIBS) $(FREEGLUT_LIBS)

SDK_FLAGS+="USE_APP=yes"
SDK_FLAGS+="APP_ID=kard"

export GENERIC_CFLAGS
export GENERIC_LIBS
export GENERIC_LIB_PATHS
export GENERIC_INCLUDES
export GENERIC_BINARIES_SOURCE_DIR
export GENERIC_BINARIES_COMMON_SOURCE_FILES
export GENERIC_TARGET_BINARIES_PREFIX
export GENERIC_TARGET_BINARIES_DIR
export GENERIC_BINARIES_SOURCE_ENTRYPOINTS

# Bug fix ...
export GENERIC_LIBRARY_SOURCE_DIR=$(GENERIC_BINARIES_SOURCE_DIR)


.PHONY: $(TARGET) build_libs

all: build_libs $(TARGET)

$(TARGET):
	@$(MAKE) -C $(SDK_PATH)/VP_SDK/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) USE_LINUX=yes
	rm -f sym_$(TARGET)
	#mv $(ARDRONE_TARGET_DIR)/ardrone_testing_tool $(TARGET)
	#mv $(TARGET) $(ARDRONE_TARGET_DIR)/

$(MAKECMDGOALS): build_libs
	@$(MAKE) -C $(SDK_PATH)/VP_SDK/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) USE_LINUX=yes

build_libs:
	@$(MAKE) -C $(SDK_PATH)/Soft/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) USE_LINUX=yes

