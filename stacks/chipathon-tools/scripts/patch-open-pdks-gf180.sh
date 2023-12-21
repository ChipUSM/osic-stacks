#!/bin/bash
set -ex

function gf180_delete_repos() {
    rm -rf globalfoundries-pdk-libs-gf180mcu_fd_pr
    rm -rf globalfoundries-pdk-libs-gf180mcu_fd_pv
}

function gf180_download_repos() {
    gf180_delete_repos

    git clone https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr.git
    git clone https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pv.git
}

function gf180_patch_xschemrc() {
    FILEPATH=$PDK_ROOT/gf180mcuD/libs.tech/xschem/xschemrc

    ORIGINAL='append XSCHEM_LIBRARY_PATH :$env(PWD)'
    REPLACE='append XSCHEM_LIBRARY_PATH :$env(PDK_ROOT)/$env(PDK)/libs.tech/xschem'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH

    ORIGINAL='set 180MCU_MODELS ${PDK_ROOT}/models/ngspice'
    REPLACE='set 180MCU_MODELS $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH
}

function gf180_patch_klayout_pcells() {
    # Delete old volare pymacros, use the pcells from efabless repo.

    rm -rf $KLAYOUT_HOME/pymacros
    mv globalfoundries-pdk-libs-gf180mcu_fd_pr/cells/klayout/pymacros $KLAYOUT_HOME
}

function gf180_patch_klayout_tech_clean() {
    # DRC and LVS is obsolete, and the copy is made on $KLAYOUT_HOME/
    rm -rf $KLAYOUT_HOME/tech/drc
    rm -rf $KLAYOUT_HOME/tech/lvs

    # .lym should be on $KLAYOUT_HOME/pymacros
    rm -rf $KLAYOUT_HOME/tech/gf180mcu.lym
}

function gf180_patch_klayout_drc_lvs() {
    rm -rf $KLAYOUT_HOME/drc
    rm -rf $KLAYOUT_HOME/lvs

    cp globalfoundries-pdk-libs-gf180mcu_fd_pv/klayout/drc $KLAYOUT_HOME
    cp globalfoundries-pdk-libs-gf180mcu_fd_pv/klayout/lvs $KLAYOUT_HOME
}

function gf180_patch_klayout_dropdown() {
    # dropdown menu should live on $KLAYOUT_HOME/macro
    # Depends on $KLAYOUT_HOME/drc $KLAYOUT_HOME/lvs
    mv globalfoundries-pdk-libs-gf180mcu_fd_pr/rules/klayout/macros $KLAYOUT_HOME

    # Make D the default variant
    sed -i "s/variant: C/variant: D/g" $KLAYOUT_HOME/macros/*_options.yml
}

function gf180_patch_klayout_precheck_drc() {
    wget -O $KLAYOUT_HOME/drc/$PRECHECK_GF_FILE $PRECHECK_REPO/$PRECHECK_GF_FILE
}

function gf180_patch_klayout_lyp() {
    # If $KLAYOUT_HOME/tech is not modified, this has no dependencies
    mv gf180mcu.lyp $KLAYOUT_HOME/tech/gf180mcu.lyp
}

function gf180_patch() {
    # volare pdk should be installed with ./volare_install.sh

    export KLAYOUT_HOME="$PDK_ROOT/gf180mcuD/libs.tech/klayout"

    gf180_download_repos

    gf180_patch_xschemrc
    gf180_patch_klayout_pcells
    gf180_patch_klayout_tech_clean
    gf180_patch_klayout_drc_lvs
    gf180_patch_klayout_dropdown
    gf180_patch_klayout_precheck_drc
    gf180_patch_klayout_lyp

    gf180_delete_repos
}


SCRIPT_DIR=$PWD

# This files can be downloaded directly
# - sky130A_mr.drc
# - gf180mcuD_mr.drc
PRECHECK_REPO=https://raw.githubusercontent.com/efabless/mpw_precheck/main/checks/tech-files/
PRECHECK_GF_FILE=gf180mcuD_mr.drc
PRECHECK_SKY_FILE=sky130A_mr.drc

sudo aur-install wget
pip install docopt --upgrade --break-system-packages

gf180_patch

sudo aur-install gedit xterm gvim