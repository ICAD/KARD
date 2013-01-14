#####################################################
#	Pilot Makefile
#####################################################
SDK_PATH:=$(shell pwd)/../../ARDrone/ARDroneLib
PC_TARGET=yes
USE_LINUX=yes

ifdef MYKONOS
   include $(ARDRONE_CUSTOM_CONFIG)
   include $(ARDRONE_BUILD_CONFIG)
else
   include $(SDK_PATH)/Soft/Build/custom.makefile
   include $(SDK_PATH)/Soft/Build/config.makefile
endif

RELEASE_BUILD=no
ifeq "$(RELEASE_BUILD)" "yes"
   KARD_TARGET_DIR=$(shell pwd)/Build/Release
else
   KARD_TARGET_DIR=$(shell pwd)
endif

TARGET=pilot

SRC_DIR:=$(shell pwd)

OPENNI_INCLUDE=/usr/include/ni/
OPENNI_LIBS=-lOpenNI

OPENCV_CFLAGS=`pkg-config --cflags opencv`
OPENCV_LIBS=`pkg-config --libs opencv`

OPENGL_LIBS=`pkg-config --libs glu glew`

GENERIC_BINARIES_SOURCE_DIR:=$(SRC_DIR)

GENERIC_BINARIES_COMMON_SOURCE_FILES+=\
video/pre_stage.c \
video/post_stage.c \
video/display_stage.c

GENERIC_INCLUDES+= \
	$(SRC_DIR) \
	$(LIB_DIR) \
	$(SDK_PATH)/Soft/Common \
	$(SDK_PATH)/Soft/Lib \
	$(OPENNI_INCLUDE) \
	$(VISION_DIR)

GENERIC_TARGET_BINARIES_PREFIX=
GENERIC_TARGET_BINARIES_DIR=$(KARD_TARGET_DIR)
GENERIC_BINARIES_SOURCE_ENTRYPOINTS+= pilot.c

GENERIC_INCLUDES:=$(addprefix -I,$(GENERIC_INCLUDES))
GENERIC_INCLUDES+=$(OPENCV_CFLAGS)

GENERIC_LIB_PATHS=-L$(GENERIC_TARGET_BINARIES_DIR)
GENERIC_LIBS=-lpc_ardrone -lrt
GENERIC_LIBS+=$(OPENCV_LIBS) $(OPENGL_LIBS) -lOpenNI

SDK_FLAGS+="USE_APP=yes"
SDK_FLAGS+="APP_ID=pilot"

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
	@$(MAKE) -w -C $(SDK_PATH)/VP_SDK/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) USE_LINUX=yes
	find $(KARD_TARGET_DIR) -name "sym_*" -exec rm "{}" \;

$(MAKECMDGOALS): build_libs
	@$(MAKE) -w -C $(SDK_PATH)/VP_SDK/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) USE_LINUX=yes

build_libs:
	@$(MAKE) -w -C $(SDK_PATH)/Soft/Build $(TMP_SDK_FLAGS) $(SDK_FLAGS) $(MAKECMDGOALS) USE_LINUX=yes

