#!/bin/bash

BASE=/media/graham/work/dev/z80
PROJECTBASE=$BASE/Projects/terminal/test/test2
SRC=$PROJECTBASE
OUT=$PROJECTBASE
cd $PROJECTBASE
clear

function compile( ) {
   echo Compiling $2
   z80asm --verbose -v --input $SRC/$2 --output $OUT/$1.bin
}
# build the code
cd $PROJECTBASE

compile "test2"   "test2.asm"


#build the disk image
cd $BASE
java -jar $BASE/bin/HDDFileEditor.jar script=$PROJECTBASE/diskbuild.script

#Start fuse
HD="--simpleide --simpleide-slavefile=$BASE/dsk/simple.hdf"
FDD="--plus3disk $PROJECTBASE/test2.dsk"
#JS="--kempston --joystick-1 /dev/input/js1 --joystick-1-output 2"
#NOL=" --no-auto-load"
#MOUSE="--kempston-mouse"

fuse --machine plus3e $MOUSE $NOL $FDD $HD $JS
