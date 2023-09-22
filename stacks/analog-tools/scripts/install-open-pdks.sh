#!/bin/bash

set -e

if [ -d xschemrc ]; then
    echo File xschemrc not found
    return -1
fi

export OPEN_PDKS_VERSION="dd7771c384ed36b91a25e9f8b314355fc26561be"
export SCRIPT_DIR=.

####################
# INSTALL SKY130 PDK
####################

volare enable "${OPEN_PDKS_VERSION}" --pdk sky130

# remove version sky130B to save space (efabless TO use mostly sky130A)
rm -rf "$PDK_ROOT"/volare/sky130/versions/*/sky130B
rm -rf "$PDK_ROOT"/sky130B

if [ -d "$PDK_ROOT/sky130A" ]; then
	# apply SPICE mode file reduction (for the variants that exist)
	# add custom IIC bind keys to magicrc

    cd "$PDK_ROOT/sky130A/libs.tech/ngspice" || exit 1
	"$SCRIPT_DIR/iic-spice-model-red.py" sky130.lib.spice tt
	"$SCRIPT_DIR/iic-spice-model-red.py" sky130.lib.spice ss
	"$SCRIPT_DIR/iic-spice-model-red.py" sky130.lib.spice ff

	# FIXME: Repair klayout tech file
	sed -i 's/>sky130</>sky130A</g' "$PDK_ROOT/sky130A/libs.tech/klayout/tech/sky130A.lyt"
	sed -i 's/sky130.lyp/sky130A.lyp/g' "$PDK_ROOT/sky130A/libs.tech/klayout/tech/sky130A.lyt"
	sed -i '/<base-path>/c\ <base-path/>' "$PDK_ROOT/sky130A/libs.tech/klayout/tech/sky130A.lyt"
	# shellcheck disable=SC2016
	sed -i '/<original-base-path>/c\ <original-base-path>$PDK_ROOT/$PDK/libs.tech/klayout</original-base-path>' "$PDK_ROOT/sky130A/libs.tech/klayout/tech/sky130A.lyt"
fi

######################
# INSTALL GF180MCU PDK
######################

volare enable "${OPEN_PDKS_VERSION}" --pdk gf180mcu

if [ -d "$PDK_ROOT/sky130A" ]; then

	rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuA
	rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuB
	rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuD
	rm -rf $PDK_ROOT/gf180mcuA
	rm -rf $PDK_ROOT/gf180mcuB
	rm -rf $PDK_ROOT/gf180mcuD

	mv $KLAYOUT_HOME/pymacros temp
	mkdir $KLAYOUT_HOME/pymacros
	mv temp $KLAYOUT_HOME/pymacros/cells
	mv $KLAYOUT_HOME/tech/gf180mcu.lym $KLAYOUT_HOME/pymacros

	mv xschemrc $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc
fi

rm -rf $SCRIPT_DIR/iic-spice-model-red.py