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


alias ls="ls --color=auto -XA"
alias grep="grep --color=auto"

PS1="[\u@\h \W]\$ "

## Tools Support

alias xschem='xschem -b --rcfile $PDKPATH/libs.tech/xschem/xschemrc'
alias xschemtcl='xschem --rcfile $PDKPATH/libs.tech/xschem/xschemrc'