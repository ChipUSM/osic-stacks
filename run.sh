#!/bin/bash
set -e

# IMAGE=akilesalreadytaken/analog-xk:latest
IMAGE=akilesalreadytaken/analog-tools:latest
# IMAGE=git.1159.cl/mario1159/analog-xk-web:latest

CALL=
function parse () {
    while getopts ":hsvp:k:" option; do
        case $option in
            h) documentation   ;;
            s) CALL="echo [CMD] "      ;;
            #v) ENABLE_VNC=1     ;;   # VNC not working rigth now
            p) DESIGNS=$OPTARG ;;
            k) PDK=$OPTARG     ;;
            \?) echo "Error: Invalid option"; documentation ;;
        esac
    done
}

function documentation () {
    echo "Usage: run.bat [ OPTIONS ]"
    echo ""
    echo "  -h             Show usage information"
    echo "  -s             See the commands to be executed"
    echo "  -p PATH        Link to a directory"
    # echo "  -v             Enable the vnc in port "https:\\localhost:8444""
    # echo "                 If vnc is not working, execute:"
    # echo "                    $ xfce4-session --display=:1 &"
    echo "  -k PDK         Set the PDK to be used (gf180mcuC | sky130A)"
    echo "                 By default: gf180mcuC"
    exit
}

function run () {
    # Set fixed parameters
    ####################
    [ -z "${DESIGNS+x}" ] && DESIGNS=$PWD
    DESIGNS=$( realpath $DESIGNS )

    [ -z "${PDK+x}" ]             && PDK=gf180mcuC

    [ -z "${DOCKER_USER+x}" ]     && DOCKER_USER=git.1159.cl/mario1159
    [ -z "${DOCKER_IMAGE+x}" ]    && DOCKER_IMAGE=analog-xk
    [ -z "${DOCKER_TAG+x}" ]      && DOCKER_TAG=latest

    [ -z "${CONTAINER_USER+x}" ]  && CONTAINER_USER=$(id -u)
    [ -z "${CONTAINER_GROUP+x}" ] && CONTAINER_GROUP=$(id -g)

    [ -z "${CONTAINER_NAME+x}" ]  && CONTAINER_NAME=analog-tools

    [ -z "${JUPYTER_PORT+x}" ]    && JUPYTER_PORT=8888
    [ -z "${VNC_PORT+x}" ]        && VNC_PORT=8444

    # Validate parameters
    #####################
    if [[ ${CONTAINER_USER} -ne 0 ]]  &&  [[ ${CONTAINER_USER} -lt 1000 ]]; then
            prt_str="# [WARNING] Selected User ID ${CONTAINER_USER} is below 1000. This ID might interfere with User-IDs inside the container and cause undefined behavior! #"
            printf -- '#%.0s' $(seq 1 ${#prt_str})
            echo
            echo "${prt_str}"
            printf -- '#%.0s' $(seq 1 ${#prt_str})
            echo
    fi

    if [[ ${CONTAINER_GROUP} -ne 0 ]]  && [[ ${CONTAINER_GROUP} -lt 1000 ]]; then
            prt_str="# [WARNING] Selected Group ID ${CONTAINER_GROUP} is below 1000. This ID might interfere with Group-IDs inside the container and cause undefined behavior! #"
            printf -- '#%.0s' $(seq 1 ${#prt_str})
            echo
            echo "${prt_str}"
            printf -- '#%.0s' $(seq 1 ${#prt_str})
            echo
    fi

    # Check if the container exists and if it is running.
    if [ "$(docker ps -q -f name="${CONTAINER_NAME}")" ]; then
        echo "[WARNING] Container is running!"
        echo "[HINT] It can also be stopped with \"docker stop ${CONTAINER_NAME}\" and removed with \"docker rm ${CONTAINER_NAME}\" if required."
        echo
        echo -n "Press \"s\" to stop, and \"r\" to stop & remove: "
        read -r -n 1 k <&1
        echo
        if [[ $k = s ]] ; then
            $CALL docker stop "${CONTAINER_NAME}"
        elif [[ $k = r ]] ; then
            $CALL docker stop "${CONTAINER_NAME}"
            $CALL docker rm "${CONTAINER_NAME}"
        fi
        exit
    fi

    # If the container exists but is exited, it is restarted.
    if [ "$(docker ps -aq -f name="${CONTAINER_NAME}")" ]; then
        echo "[WARNING] Container ${CONTAINER_NAME} exists."
        echo "[HINT] It can also be restarted with \"docker start ${CONTAINER_NAME}\" or removed with \"docker rm ${CONTAINER_NAME}\" if required."
        echo
        echo -n "Press \"s\" to start, and \"r\" to remove: "
        read -r -n 1 k <&1
        echo
        if [[ $k = s ]] ; then
            $CALL docker start "${CONTAINER_NAME}"
        elif [[ $k = r ]] ; then
            $CALL docker rm "${CONTAINER_NAME}"
        fi
        exit
    fi

    # Set environment, variables and run the container
    ##################################################

    echo "[INFO] Container does not exist, creating ${CONTAINER_NAME} ..."

    PARAMS="-d"
    PARAMS="$PARAMS --name $CONTAINER_NAME"
    PARAMS="$PARAMS -e PDK=$PDK"
    PARAMS="$PARAMS --user ${CONTAINER_USER}:${CONTAINER_GROUP}"
    PARAMS="$PARAMS --security-opt seccomp=unconfined"
    PARAMS="$PARAMS -p $JUPYTER_PORT:8888"
    PARAMS="$PARAMS -v $DESIGNS:/home/designer/shared"
    PARAMS="$PARAMS -v /tmp/.X11-unix:/tmp/.X11-unix"

    if [ -z "${ENABLE_VNC+x}" ]; then 
        PARAMS="$PARAMS -e DISPLAY=$DISPLAY"
        PARAMS="$PARAMS -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
        PARAMS="$PARAMS -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
    else
        PARAMS="$PARAMS -p $VNC_PORT:8444"
        # Should use WSL_DISTRO_NAME ?
        PARAMS="$PARAMS -v /mnt/wslg:/mnt/wsl"
    fi

    if [ -z "${IMAGE+x}" ]; then 
        IMAGE=$DOCKER_USER/$DOCKER_IMAGE:$DOCKER_TAG
    fi

    echo "[INFO] Container based on $IMAGE"

    $CALL docker run $PARAMS $IMAGE $COMMAND

    attach_shell
}

function attach_shell () {
    $CALL docker exec -it $CONTAINER_NAME bash
}


function restart_shell () {
    $CALL docker start $CONTAINER_NAME
    attach_shell
}

parse $@
run