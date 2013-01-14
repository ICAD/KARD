#####################################################
#	Vision Makefile
#####################################################
TARGET=vision
TARGET_FILE=$(TARGET).c
TARGET_FILE_HEADER=$(TARGET).h
TEST_FILE=$(TARGET)_test
UNAME := $(shell uname)
LIBRARY_NAME=kard$(TARGET)

ifeq ($(UNAME), Linux)
	INCLUDE_DIR=/usr/include
	LIB_DIR=/usr/local/lib
	OPENNI_INCLUDE=$(INCLUDE_DIR)/ni/
	OPENGL_LIBS=`pkg-config --libs glu glew`
endif
ifeq ($(UNAME), Darwin)
	INCLUDE_DIR=/usr/local/include
	OPENNI_INCLUDE=$(INCLUDE_DIR)/ni/
	OPENGL_LIBS=`pkg-config --libs glew`
endif

OPENNI_LIBS=-lOpenNI
OPENCV_LIBS=`pkg-config --libs opencv`
OPENCV_CFLAGS=`pkg-config --cflags opencv`

PTHREAD_LIBS=-lpthread_workqueue

# cumulative links
INCLUDES = $(OPENNI_INCLUDE) $(INCLUDE_DIR)
LIBRARIES = \
	$(OPENNI_LIBS) \
	$(OPENGL_LIBS) \
	$(OPENCV_LIBS) \
	$(PHTREAD_LIBS)

ifeq ($(UNAME), Linux)
	LIBRARIES += -lglut
endif

INCLUDES:=$(addprefix -I,$(INCLUDES))
INCLUDES+=$(OPENCV_CFLAGS)

all: $(TARGET)

$(TARGET): $(TARGET_FILE) $(TARGET_FILE_HEADER)
	gcc -w -fPIC -c $(TARGET_FILE) $(TARGET_FILE_HEADER) $(INCLUDES)
	gcc -shared -Wl,-soname,lib$(LIBRARY_NAME).so -o lib$(LIBRARY_NAME).so *.o
	rm *.gch *.o
	
test: *.c *.h $(TARGET)
	gcc -o $(TEST_FILE) $(TEST_FILE).c -L./ -I./ -l$(LIBRARY_NAME) $(LIBRARIES) $(INCLUDES)
	LD_LIBRARY_PATH=. ./$(TEST_FILE)

clean:
	rm -rf *~ *.o *.gch $(TARGET) lib$(LIBRARY_NAME).so $(TEST_FILE)

