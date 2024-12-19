#!/usr/bin/env bash
set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Variables
MIPLIBDIR="mip/libraries"
BINNAME="libcbc.lib"
COINDIR="coinlibs"
COINBREW_URL="https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew"

echo "Python MIP libraries directory: $MIPLIBDIR"
echo "CBC library binary name: $BINNAME"

# Clean existing libraries
rm -rf $MIPLIBDIR/*
mkdir -p $MIPLIBDIR

# Create and navigate to coinlibs directory
mkdir -p $COINDIR
cd $COINDIR

# Download coinbrew if it doesn't exist
if [[ ! -f coinbrew ]]; then
    wget $COINBREW_URL -O coinbrew
    chmod u+x coinbrew
fi

# Build CBC with coinbrew
./coinbrew build --static Cbc@master --prefix=dist
echo "CBC build completed successfully."

cd ..

# Ensure CXX is defined
if [[ -z "${CXX:-}" ]]; then
    echo "CXX is not set. Defaulting to g++."
    CXX=g++
fi

# Compile the shared library
$CXX -shared -Ofast -fPIC -o $MIPLIBDIR/$BINNAME \
    -I${COINDIR}/dist/include/coin-or/ \
    -DCBC_THREAD \
    $COINDIR/Cbc/src/Cbc_C_Interface.cpp \
    -L${COINDIR}/dist/lib/ \
    -lCbc -lCgl -lClp -lCoinUtils -lOsi -lOsiCbc -lOsiClp \
    -lreadline -lbz2 -lz \
    -lgfortran -lquadmath -lm -lstdc++ \
    -static-libgcc -static-libstdc++ -static-libgfortran

echo "Shared library compiled successfully."

# Install the Python package
pip install . -vv
