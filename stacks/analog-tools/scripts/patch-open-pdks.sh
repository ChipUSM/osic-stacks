#!/bin/bash
set -e

SCRIPT_DIR=$PWD
DROPDOWN_REPO="https://github.com/mabrains/globalfoundries-pdk-libs-gf180mcu_fd_pr"

# This files can be downloaded directly
# - sky130A_mr.drc
# - gf180mcuC_mr.drc
PRECHECK_REPO=https://raw.githubusercontent.com/efabless/mpw_precheck/main/checks/tech-files/
PRECHECK_GF_FILE=gf180mcuC_mr.drc
PRECHECK_SKY_FILE=sky130A_mr.drc

if [ -d $SCRIPT_DIR/iic-spice-model-red.py ]; then
    echo File iic-spice-model.red.py not found
    return -1
fi

sudo aur-install wget
pip install docopt --upgrade --break-system-packages

######################
# PATCH GF180MCU PDK
######################

function gf180_patch_xschemrc() {
    FILEPATH=$PDK_ROOT/gf180mcuC/libs.tech/xschem/xschemrc

    ORIGINAL='append XSCHEM_LIBRARY_PATH :$env(PWD)'
    REPLACE='append XSCHEM_LIBRARY_PATH :$env(PDK_ROOT)/$env(PDK)/libs.tech/xschem'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH

    ORIGINAL='set 180MCU_MODELS ${PDK_ROOT}/models/ngspice'
    REPLACE='set 180MCU_MODELS $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH
}

function gf180_patch_klayout_pcells() {
    KLAYOUT_HOME="$PDK_ROOT/gf180mcuC/libs.tech/klayout"

    mv $KLAYOUT_HOME/pymacros $KLAYOUT_HOME/cells
    mkdir $KLAYOUT_HOME/pymacros
    mv $KLAYOUT_HOME/cells $KLAYOUT_HOME/pymacros
    mv $KLAYOUT_HOME/tech/gf180mcu.lym $KLAYOUT_HOME/pymacros

    rm -rf .scripts/klayout
}

function gf180_patch_klayout_dropdown() {
    # 27:00 & 36:40
    KLAYOUT_HOME="$PDK_ROOT/gf180mcuC/libs.tech/klayout"
    DROPDOWN_DIRECTORY="globalfoundries"

    git clone $DROPDOWN_REPO $DROPDOWN_DIRECTORY

    cp -r $DROPDOWN_DIRECTORY/rules/klayout/macros $KLAYOUT_HOME

    # There's no directories
    # cp -r $DROPDOWN_DIRECTORY/rules/klayout/drc/*.drc $KLAYOUT_HOME/drc
    # cp -r $DROPDOWN_DIRECTORY/rules/klayout/lvs/*.lvs $KLAYOUT_HOME/lvs

    rm -rf $DROPDOWN_DIRECTORY
}

function gf180_patch_klayout_precheck_drc() {
    KLAYOUT_HOME="$PDK_ROOT/gf180mcuC/libs.tech/klayout"
    #curl -o $KLAYOUT_HOME/drc/rule_decks/$PRECHECK_GF_FILE $PRECHECK_REPO/$PRECHECK_GF_FILE
    wget -O $KLAYOUT_HOME/drc/rule_decks/$PRECHECK_GF_FILE $PRECHECK_REPO/$PRECHECK_GF_FILE
}

function gf180_patch() {
    gf180_patch_xschemrc
    gf180_patch_klayout_pcells
    gf180_patch_klayout_dropdown
    gf180_patch_klayout_precheck_drc
}

####################
# PATCH SKY130 PDK
####################

function sky130_patch_reduced_models() {
    cd "$PDK_ROOT/sky130A/libs.tech/ngspice" || exit 1
    "$SCRIPT_DIR/iic-spice-model-red.py" sky130.lib.spice tt
    "$SCRIPT_DIR/iic-spice-model-red.py" sky130.lib.spice ss
    "$SCRIPT_DIR/iic-spice-model-red.py" sky130.lib.spice ff

    cd "$SCRIPT_DIR"
    rm -rf "iic-spice-model-red.py"
}

function sky130_patch_klayout_lyt() {
    KLAYOUT_HOME="$PDK_ROOT/sky130A/libs.tech/klayout"
    FILEPATH="$KLAYOUT_HOME/tech/sky130A.lyt"

    sed -i 's/>sky130</>sky130A</g' $FILEPATH
    sed -i 's/sky130.lyp/sky130A.lyp/g' $FILEPATH
    sed -i '/<base-path>/c\ <base-path/>' $FILEPATH
    sed -i '/<original-base-path>/c\ <original-base-path>$PDK_ROOT/$PDK/libs.tech/klayout</original-base-path>' $FILEPATH
}

function sky130_patch_klayout_lym () {
    KLAYOUT_HOME="$PDK_ROOT/sky130A/libs.tech/klayout"
    # ERROR: Reading /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/sky130.lym: XML parser error: invalid name for processing instruction in line 17, column 6
    # ERROR: Reading /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/sky130.lym: XML parser error: invalid name for processing instruction in line 17, column 6
    # ERROR: Reading /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/sky130.lym: XML parser error: invalid name for processing instruction in line 17, column 6
    FILENAME="$KLAYOUT_HOME/pymacros/sky130.lym"
    LINE=17
    ( sed -n ${LINE}' {p;q}' $FILENAME ; sed "${LINE}d" $FILENAME ) > $FILENAME
}

function sky130_patch_klayout_pcells() {
    KLAYOUT_HOME="$PDK_ROOT/sky130A/libs.tech/klayout"
    # Fixing the above, the cells indicates the following:
    # ERROR: /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/cells/via_generator.py:23: ModuleNotFoundError: No module named 'gdsfactory.types'
    #   /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/cells/via_generator.py:23
    #   /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/cells/vias.py:20
    #   /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/cells/__init__.py:21
    #   /home/designer/.volare/sky130A/libs.tech/klayout/pymacros/sky130.lym:9 (class ModuleNotFoundError)
    echo hola
}

function sky130_patch_klayout_precheck_drc() {
    KLAYOUT_HOME="$PDK_ROOT/sky130A/libs.tech/klayout"
    wget -O $KLAYOUT_HOME/drc/$PRECHECK_SKY_FILE $PRECHECK_REPO/$PRECHECK_SKY_FILE
}

function sky130_patch() {
    sky130_patch_reduced_models
    sky130_patch_klayout_lyt
    # sky130_patch_klayout_lym          # TODO: The file disappears
    # sky130_patch_klayout_pcells       # TODO: Before fixing lym, this explodes
    sky130_patch_klayout_precheck_drc
}

gf180_patch
sky130_patch

sudo aur-install gedit xterm gvim