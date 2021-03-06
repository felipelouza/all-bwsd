CCLIB=-lsdsl -ldivsufsort -ldivsufsort64 -Wno-comment -fopenmp
VLIB= -g -O0

LIB_DIR = ${HOME}/lib
INC_DIR = ${HOME}/include
MY_CXX_FLAGS= -std=c++14 -Wall -DNDEBUG -D__STDC_FORMAT_MACROS -fomit-frame-pointer -Wno-char-subscripts -Wno-sign-compare -Wno-vla
#-D_FILE_OFFSET_BITS=64

MY_CXX_OPT_FLAGS= -O3 -m64 
#MY_CXX_OPT_FLAGS= $(VLIB)
MY_CXX=g++

##

LIBOBJ = \
	lib/file.o\
	lib/utils.o\
	external/gsacak.o\
	external/malloc_count/malloc_count.o
	
##

M64 = 0
OMP = 1
DEBUG = 0

#Alternatives for Algorithm 1
SD_VECTOR = 1
WT = 0
OPT_VERSION = 1
WORST_CASE = 0

##

LFLAGS = -lm -ldl

DEFINES = -DDEBUG=$(DEBUG) -DM64=$(M64) -DOMP=$(OMP) -DWT=$(WT) -DSD_VECTOR=$(SD_VECTOR) -DOPT_VERSION=$(OPT_VERSION) -DWORST_CASE=$(WORST_CASE)

CXX_FLAGS=$(MY_CXX_FLAGS) $(MY_CXX_OPT_FLAGS) -I$(INC_DIR) -L$(LIB_DIR) $(LFLAGS) $(DEFINES)

CLAGS= -DSYMBOLBYTES=1
CFLAGS += $(DEFINES)

##

DIR = dataset/
#INPUT = input.100.txt
INPUT = reads-10000.fastq

K	= 3
MODE 	= 1

##

all: compile

clean:
	\rm -f *.o  external/*.o lib/*o external/malloc_count/*.o bwsd

remove:
	\rm -f $(DIR)*.bin $(DIR)sdsl/*

##

lib: lib/file.c lib/utils.c external/gsacak.c external/malloc_count/malloc_count.o 
	$(MY_CXX) $(CXX_FLAGS) $(DEFINES) -c lib/file.c -o lib/file.o 
	$(MY_CXX) $(CXX_FLAGS) $(DEFINES) -c lib/utils.c -o lib/utils.o 
	$(MY_CXX) $(CXX_FLAGS) $(DEFINES) -c external/gsacak.c -o external/gsacak.o 


compile: lib main.cpp ${LIBOBJ} 
	$(MY_CXX) main.cpp $(CCLIB) -o bwsd ${LIBOBJ} $(CXX_FLAGS) 

run:
	./bwsd $(DIR)$(INPUT) $(K) -M $(MODE)

valgrind:
	valgrind --tool=memcheck --leak-check=full --track-origins=yes ./bwsd $(DIR)$(INPUT) $(K) -M $(MODE) 
