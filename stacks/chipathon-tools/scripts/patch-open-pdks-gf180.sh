#!/bin/bash
set -ex

function _gf180mcuD_clean_install() {
    # Re-installs gf180mcuD

    rm -rf $PDK_ROOT/gf180mcu*
    rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_COMMIT

    volare enable --pdk gf180mcu $OPEN_PDKS_COMMIT

    rm -rf $PDK_ROOT/gf180mcuA
    rm -rf $PDK_ROOT/gf180mcuB
    rm -rf $PDK_ROOT/gf180mcuC

    rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_COMMIT/gf180mcuA
    rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_COMMIT/gf180mcuB
    rm -rf $PDK_ROOT/volare/gf180mcu/versions/$OPEN_PDKS_COMMIT/gf180mcuC
}


function gf180_delete_repos() {
    rm -rf globalfoundries-pdk-libs-gf180mcu_fd_pr
    rm -rf globalfoundries-pdk-libs-gf180mcu_fd_pv
}


function gf180_download_repos() {
    gf180_delete_repos

    git clone --depth 1 https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr.git
    git clone --depth 1 https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pv.git
}


function gf180_patch_ngspice_primitives() {
    NGSPICE_TECH=$PDK_ROOT/gf180mcuD/libs.tech/ngspice
    
    rm -rf $NGSPICE_TECH
    mv globalfoundries-pdk-libs-gf180mcu_fd_pr/models/ngspice $NGSPICE_TECH
}


function gf180_patch_xyce_primitives() {
    XYCE_TECH=$PDK_ROOT/gf180mcuD/libs.tech/xyce

    rm -rf $XYCE_TECH
    mv globalfoundries-pdk-libs-gf180mcu_fd_pr/models/xyce $XYCE_TECH
}

function gf180_patch_xschem_primitives() {
    # Replace volare xschem dir with efabless one
    XSCHEM_TECH=$PDK_ROOT/gf180mcuD/libs.tech/xschem

    rm -rf $XSCHEM_TECH
    mv globalfoundries-pdk-libs-gf180mcu_fd_pr/cells/xschem $XSCHEM_TECH
}

function gf180_patch_xschem_xschemrc() {
    FILEPATH=$PDK_ROOT/gf180mcuD/libs.tech/xschem/xschemrc

    # Add gf180mcuD symbols to xschem path
    ORIGINAL='append XSCHEM_LIBRARY_PATH :$env(PWD)'
    REPLACE='append XSCHEM_LIBRARY_PATH :$env(PDK_ROOT)/gf180mcuD/libs.tech/xschem'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH

    # Update 180MCU_MODELS
    ORIGINAL='set 180MCU_MODELS ${PDK_ROOT}/models/ngspice'
    REPLACE='set 180MCU_MODELS $env(PDK_ROOT)/gf180mcuD/libs.tech/ngspice'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH

    # Allow setting of symbol paths with XSCHEM_USER_LIBRARY_PATH env variable
    echo '' >> $FILEPATH
    echo '# open_pdks-specific' >> $FILEPATH
    echo 'set XSCHEM_START_WINDOW ${PDK_ROOT}/gf180mcuD/libs.tech/xschem/tests/0_top.sch' >> $FILEPATH
    echo 'append XSCHEM_LIBRARY_PATH :${PDK_ROOT}/gf180mcuD/libs.tech/xschem' >> $FILEPATH
    echo '' >> $FILEPATH
    echo '# allow a user-specific path add-on' >> $FILEPATH
    echo 'if { [info exists ::env(XSCHEM_USER_LIBRARY_PATH) ] } {' >> $FILEPATH
    echo '    append XSCHEM_LIBRARY_PATH :$env(XSCHEM_USER_LIBRARY_PATH)' >> $FILEPATH
    echo '}' >> $FILEPATH
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

    mv globalfoundries-pdk-libs-gf180mcu_fd_pv/klayout/drc $KLAYOUT_HOME
    mv globalfoundries-pdk-libs-gf180mcu_fd_pv/klayout/lvs $KLAYOUT_HOME
}

function gf180_patch_klayout_dropdown() {
    # dropdown menu should live on $KLAYOUT_HOME/macro
    # Depends on $KLAYOUT_HOME/drc $KLAYOUT_HOME/lvs
    mv globalfoundries-pdk-libs-gf180mcu_fd_pr/rules/klayout/macros $KLAYOUT_HOME

    # Make D the default variant in {drc lvs}_options.yml
    FILEPATH=$KLAYOUT_HOME/macros/*_options.yml
    
    ORIGINAL='variant: C'
    REPLACE='variant: D'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH

    # Make D default on .lym
    FILEPATH=$KLAYOUT_HOME/macros/gf180mcu_options.lym

    ORIGINAL=';"C"'
    REPLACE=';"D"'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH

    ORIGINAL='], 2)'
    REPLACE='], 3)'
    sed -i "s\\$ORIGINAL\\$REPLACE\g" $FILEPATH
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

    gf180_patch_ngspice_primitives

    gf180_patch_xyce_primitives

    gf180_patch_xschem_primitives
    gf180_patch_xschem_xschemrc

    gf180_patch_klayout_pcells
    gf180_patch_klayout_tech_clean
    gf180_patch_klayout_drc_lvs
    gf180_patch_klayout_dropdown
    gf180_patch_klayout_precheck_drc
    gf180_patch_klayout_lyp

    gf180_delete_repos
}

source ./global-variables.sh

#_gf180mcuD_clean_install
pip install docopt --upgrade --break-system-packages
gf180_patch
