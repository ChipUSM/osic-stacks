export PDK_ROOT=/home/designer/.volare
export OPEN_PDKS_COMMIT="cd1748bb197f9b7af62a54507de6624e30363943"

# This files can be downloaded directly
# - sky130A_mr.drc
# - gf180mcuD_mr.drc
export PRECHECK_REPO=https://raw.githubusercontent.com/efabless/mpw_precheck/main/checks/tech-files/
export PRECHECK_GF_FILE=gf180mcuD_mr.drc
export PRECHECK_SKY_FILE=sky130A_mr.drc

export SCRIPT_DIR=$PWD