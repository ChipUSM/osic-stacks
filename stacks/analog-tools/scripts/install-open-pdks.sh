#!/bin/bash

set -e

export OPEN_PDKS_VERSION="dd7771c384ed36b91a25e9f8b314355fc26561be"
export SCRIPT_DIR=$PWD

if [ -d xschemrc ]; then
    echo File xschemrc not found
    return -1
fi

if [ -d $SCRIPT_DIR/iic-spice-model-red.py ]; then
    echo File iic-spice-model.red.py not found
    return -1
fi

######################
# INSTALL GF180MCU PDK
######################

export PDK=gf180mcu

volare enable "${OPEN_PDKS_VERSION}" --pdk "${PDK}"

rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuA
rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuB
rm -rf $PDK_ROOT/volare/gf180mcu/versions/*/gf180mcuD
rm -rf $PDK_ROOT/gf180mcuA
rm -rf $PDK_ROOT/gf180mcuB
rm -rf $PDK_ROOT/gf180mcuD

export KLAYOUT_HOME="$PDK_ROOT/gf180mcuC/libs.tech/klayout"

mv $KLAYOUT_HOME/pymacros temp
mkdir $KLAYOUT_HOME/pymacros
mv temp $KLAYOUT_HOME/pymacros/cells
mv $KLAYOUT_HOME/tech/gf180mcu.lym $KLAYOUT_HOME/pymacros

mv "$SCRIPT_DIR/xschemrc" $PDK_ROOT/gf180mcuC/libs.tech/xschem/xschemrc

rm -rf .scripts/klayout


####################
# INSTALL SKY130 PDK
####################

export PDK=sky130

volare enable "${OPEN_PDKS_VERSION}" --pdk "${PDK}"

# remove version sky130B to save space (efabless TO use mostly sky130A)
rm -rf "$PDK_ROOT"/volare/sky130/versions/*/sky130B
rm -rf "$PDK_ROOT"/sky130B

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

cd "$SCRIPT_DIR"



rm -rf "$SCRIPT_DIR/iic-spice-model-red.py"