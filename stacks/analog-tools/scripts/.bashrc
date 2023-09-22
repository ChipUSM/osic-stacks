[[ $- != *i* ]] && return

case "$PDK" in
gf180mcuC)
    export PDKPATH=$PDK_ROOT/$PDK
    export STD_CELL_LIBRARY=gf180mcu_fd_sc_mcu7t5v0
    ;;
sky130A)
    export PDKPATH=$PDK_ROOT/$PDK
    export STD_CELL_LIBRARY=sky130_fd_sc_hd
    ;;
*)
    echo "PDK not defined, using default one (gf180mcuC)"
    export PDK=gf180mcuC
    export PDKPATH=$PDK_ROOT/$PDK
    export STD_CELL_LIBRARY=gf180mcu_fd_sc_mcu7t5v0
    ;;
esac

function git_branch {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ "$branch" != "" ]; then
      echo "[$branch]"
    fi
}

c_res='\[\033[00m\]'      # Reset
c_bla='\[\033[01;30m\]'   # Black
c_red='\[\033[01;31m\]'   # Red
c_gre='\[\033[01;32m\]'   # Green
c_yel='\[\033[01;33m\]'   # Yellow
c_blu='\[\033[01;34m\]'   # Blue
c_pur='\[\033[01;35m\]'   # Purple
c_cya='\[\033[01;36m\]'   # Cyan
c_whi='\[\033[01;37m\]'   # White

# export PS1="${c_pur}\w $(git_branch)\n${c_res}\$ " ## This dont work :(
PS1="${c_pur}\w \n${c_res}\$ " ## This dont work :(

export KLAYOUT_HOME=$PDK_ROOT/$PDK/libs.tech/klayout
export DESIGNS="/home/designer/shared"

alias ls="ls --color=auto -XF"
alias grep="grep --color=auto"

alias xschem='xschem -b --rcfile $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc'
alias xschemtcl='xschem --rcfile $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc'

git config --global --add safe.directory $DESIGNS