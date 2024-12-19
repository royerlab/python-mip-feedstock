#!/usr/bin/env bash
# Get an updated config.sub and config.guess

MIPLIBDIR=mip/libraries
BINNAME=libcbc.lib

echo "python mip libraries directory: $MIPLIBDIR"
echo "cbc library file: $BINNAME"
rm -rf $MIPLIBDIR/*

COINDIR=coinlibs

mkdir $COINDIR
cd $COINDIR
wget https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew
chmod u+x coinbrew
./coinbrew build --static Cbc@master
echo "cbc build done"
cd ..

$CXX -shared -Ofast -fPIC -o $MIPLIBDIR/$BINNAME \
 -I${COINDIR}/dist/include/coin-or/ \
 -DCBC_THREAD \
  $COINDIR/Cbc/src/Cbc_C_Interface.cpp \
 -L/opt/gcc/lib64/ -L$COINDIR/dist/lib/ \
 -lCbc -lCgl -lClp -lCoinUtils -lOsi -lOsiCbc -lOsiClp \
 -lreadline -lbz2 -lz \
 -lgfortran -lquadmath -lm -static-libgcc -static-libstdc++ -static-libgfortran 

pip install . -vv
