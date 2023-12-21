#!/bin/bash

set -ex

source ./global-variables.sh

#pip install git+https://github.com/gdsfactory/skywater130.git git+https://github.com/gdsfactory/gf180.git --upgrade --break-system-packages
# pip install gf180 --upgrade --break-system-packages
# pip install sky130 --upgrade --break-system-packages
pip install gdsfactory[cad]==7.3.0 --break-system-packages

######################
# INSTALL GF180MCU PDK
######################

volare enable "${OPEN_PDKS_VERSION}" --pdk gf180mcu

rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuA
rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuB
rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuC
rm -rf $PDK_ROOT/gf180mcuA
rm -rf $PDK_ROOT/gf180mcuB
rm -rf $PDK_ROOT/gf180mcuC

####################
# INSTALL SKY130 PDK
####################

volare enable "${OPEN_PDKS_VERSION}" --pdk sky130

# remove version sky130B to save space (efabless TO use mostly sky130A)
rm -rf "$PDK_ROOT"/volare/sky130/versions/*/sky130B
rm -rf "$PDK_ROOT"/sky130B
