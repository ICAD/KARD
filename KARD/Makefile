#####################################################
#	KARD Makefile
#####################################################
PREFIX=kard

PILOT_BIN=pilot
PILOT_DIR=pilot
PILOT_OBJ_DIR=$(shell find ../ARDrone/ARDroneLib/Soft/Build/targets_versions/ -name "pilot*" -type d)
PILOT_LIB=lib$(PREFIX)$(PILOT_BIN).so

VISION_BIN=vision
VISION_DIR=vision
VISION_LIB=lib$(PREFIX)$(VISION_BIN).so

INCLUDE_DIR=/usr/local/include
OPENNI_DIR=$(INCLUDE_DIR)/ni

LIBRARY_DIR=/usr/local/lib

#all: .PHONY
all: .PHONY kard

.PHONY: $(VISION_BIN) $(PILOT_BIN)

$(PREFIX):
	gcc -shared -Wl,-soname,libkardpilot.so -o $(PILOT_BIN)/$(PILOT_LIB) $(PILOT_OBJ_DIR)/*.o $(PILOT_OBJ_DIR)/video/*.o
	gcc -o $(PREFIX) $(PREFIX).c -I./vision -L./vision -lkardvision -L$(LIBRARY_DIR) -I$(INCLUDE_DIR) -I/usr/include/ni -I/usr/include -I$(OPENNI_DIR) -lOpenNI

$(PILOT_BIN):
	$(MAKE) -C $(PILOT_DIR)

$(VISION_BIN):
	$(MAKE) -C $(VISION_DIR) 

clean:
	$(MAKE) -C $(PILOT_DIR) clean
	$(MAKE) -C $(VISION_DIR) clean
