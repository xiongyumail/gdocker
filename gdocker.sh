#!/bin/bash
#
#   gdocker.sh - gdocker shell
#
#   Author: XiongYu (熊宇) <xiongyu@espressif.com>
#   Copyright (c) 2020-now
#
#   License: MIT
#   GitHub: https://github.com/xiongyumail/gdocker.git
#
IMAGE_NAME="gdocker"
IMAGE_VERSION="1.0.0"

WORK_PATH=$(cd $(dirname $0); pwd)
GIT_PATH=$(cd ${WORK_PATH};git rev-parse --show-superproject-working-tree --show-toplevel | head -1)

echo ${GIT_PATH}

function hello() {
    # http://patorjk.com/software/taag/#p=display&f=3D-ASCII&t=gdocker
  cat <<'EOF'

 ________  ________  ________  ________  ___  __    _______   ________     
|\   ____\|\   ___ \|\   __  \|\   ____\|\  \|\  \ |\  ___ \ |\   __  \    
\ \  \___|\ \  \_|\ \ \  \|\  \ \  \___|\ \  \/  /|\ \   __/|\ \  \|\  \   
 \ \  \  __\ \  \ \\ \ \  \\\  \ \  \    \ \   ___  \ \  \_|/_\ \   _  _\  
  \ \  \|\  \ \  \_\\ \ \  \\\  \ \  \____\ \  \\ \  \ \  \_|\ \ \  \\  \| 
   \ \_______\ \_______\ \_______\ \_______\ \__\\ \__\ \_______\ \__\\ _\ 
    \|_______|\|_______|\|_______|\|_______|\|__| \|__|\|_______|\|__|\|__|
                                                                           
EOF
}

RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

function color_echo(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

function help_install(){
    echo "./gdocker.sh install [-h --help] [-n name] [-v version] [-t tool]"
    echo "  -h, --help            Show help"
    echo "  -n, --name            image name"
    echo "  -v, --version         image version"
    echo "  -t, --tool            install tools"
    return 0
}

function help_start(){
    echo "./gdocker.sh start [-h --help] [-n name] [-v version] [-u update] [-c command] [-p project]"
    echo "  -h, --help            Show help"
    echo "  -n, --name            image name"
    echo "  -v, --version         image version"
    echo "  -u, --update          image update"
    echo "  -c, --command         image start commad"
    echo "  -p, --project         projects path"
    return 0
}

function help_clean(){
    echo "./gdocker.sh clean [-h --help] [-n name] [-v version]"
    echo "  -h, --help            Show help"
    echo "  -n, --name            image name"
    echo "  -v, --version         image version"
    return 0
}

function install(){
    TOOL_FILE=""
    HELP=""
    while [[ $# > 0 ]];do
        key="$1"
        case $key in
            -n|--NAME)
            IMAGE_NAME="$2"
            shift # past argument
            ;;
            -v|--version)
            IMAGE_VERSION="$2"
            shift
            ;;
            -t|--tool)
            TOOL_FILE=$(readlink -f ${2})
            shift
            ;;
            -h|--help)
            HELP="1"
            shift
            ;;
            *)
            # unknown option
            ;;
        esac
        shift # past argument or value
    done
    #helping information
    [[ "$HELP" == "1" ]] && help_install && return

    WORK_RELPATH=$(realpath --relative-to=${GIT_PATH} ${WORK_PATH})
    TOOL_RELPATH=$(realpath --relative-to=${GIT_PATH} ${TOOL_FILE})

    color_echo ${BLUE} "WORK_PATH: ${WORK_PATH}"
    color_echo ${BLUE} "GIT_PATH: ${GIT_PATH}"
    color_echo ${BLUE} "WORK_RELPATH: ${WORK_RELPATH}"
    color_echo ${BLUE} "TOOL_RELPATH: ${TOOL_RELPATH}"

    if [[ "$(sudo docker images -q "${IMAGE_NAME}:${IMAGE_VERSION}" 2> /dev/null)" == "" ]]; then
      color_echo ${BLUE} "${IMAGE_NAME}:${IMAGE_VERSION} first install"
      sudo docker build --build-arg USER_NAME=${IMAGE_NAME} -f ${WORK_PATH}/Dockerfile -t "${IMAGE_NAME}:${IMAGE_VERSION}" .
    fi

    sudo docker stop ${IMAGE_NAME} 2> /dev/null
    sudo docker rm ${IMAGE_NAME} 2> /dev/null

    if [[ "${TOOL_RELPATH}" == "" ]]; then
        sudo docker run \
            --name ${IMAGE_NAME} \
            -i \
            -e MY_NAME=${IMAGE_NAME} \
            \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v $(which docker):/bin/docker \
            -v ${GIT_PATH}:/home/${IMAGE_NAME}/workspace \
            \
            "${IMAGE_NAME}:${IMAGE_VERSION}" bash
    else
        sudo docker run \
            --name ${IMAGE_NAME} \
            -i \
            -e MY_NAME=${IMAGE_NAME} \
            \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v $(which docker):/bin/docker \
            -v ${GIT_PATH}:/home/${IMAGE_NAME}/workspace \
            \
            "${IMAGE_NAME}:${IMAGE_VERSION}" /bin/bash /home/${IMAGE_NAME}/workspace/${TOOL_RELPATH}
    fi
    sudo docker commit -m "install ok" ${IMAGE_NAME} "${IMAGE_NAME}:${IMAGE_VERSION}"
    sudo docker rm ${IMAGE_NAME}

    color_echo ${GREEN} "${IMAGE_NAME}:${IMAGE_VERSION} install ok"
    return 0
}

function start(){
    CMD="bash"
    PROJECT=""
    UPDATE=""
    HELP=""
    while [[ $# > 0 ]];do
        key="$1"
        case $key in
            -n|--NAME)
            IMAGE_NAME="$2"
            shift # past argument
            ;;
            -v|--version)
            IMAGE_VERSION="$2"
            shift
            ;;
            -u|--update)
            UPDATE="1"
            shift
            ;;
            -c|--command)
            CMD="${@:2}"
            shift
            ;;
            -p|--project)
            PROJECT=$(readlink -f ${2})
            shift
            ;;
            -h|--help)
            HELP="1"
            shift
            ;;
            *)
            # unknown option
            ;;
        esac
        shift # past argument or value
    done
    #helping information
    [[ "$HELP" == "1" ]] && help_start && return

    sudo docker stop ${IMAGE_NAME} 2> /dev/null
    sudo docker rm ${IMAGE_NAME} 2> /dev/null

    sudo docker run \
        --name ${IMAGE_NAME} \
        -ti \
        \
        --privileged=true \
        --net=host \
        --ipc=host \
        \
        -e MY_NAME=${IMAGE_NAME} \
        -e DISPLAY=${DISPLAY} \
        -e XMODIFIERS=${XMODIFIERS} \
        -e GTK_IM_MODULE=${GTK_IM_MODULE} \
        -e QT_IM_MODULE=${QT_IM_MODULE} \
        \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(which docker):/bin/docker \
        -v /dev:/dev \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME/.Xauthority:/home/${IMAGE_NAME}/.Xauthority \
        -v ${GIT_PATH}:/home/${IMAGE_NAME}/workspace \
        -v ${PROJECT}:/home/${IMAGE_NAME}/projects \
        \
        "${IMAGE_NAME}:${IMAGE_VERSION}" ${CMD}

    if [ "$UPDATE" == "1" ]; then
        sudo docker commit -m "update ok" ${IMAGE_NAME} "${IMAGE_NAME}:${IMAGE_VERSION}"
    fi

    sudo docker rm ${IMAGE_NAME}

    return 0
}

function clean(){
    HELP=""
    CLEAN_FILE=""
    while [[ $# > 0 ]];do
        key="$1"
        case $key in
            -n|--NAME)
            IMAGE_NAME="$2"
            shift # past argument
            ;;
            -v|--version)
            IMAGE_VERSION="$2"
            shift
            ;;
            -h|--help)
            HELP="1"
            shift
            ;;
            *)
            # unknown option
            ;;
        esac
        shift # past argument or value
    done
    #helping information
    [[ "$HELP" == "1" ]] && help_clean && return

    cd ${WORK_PATH}

    sudo docker rmi -f "${IMAGE_NAME}:${IMAGE_VERSION}"

    return 0
}

main(){
    hello
    key="$1"
    shift
    if [[ ${key} == "install" ]]; then
        install $*
    elif [[ ${key} == "start" ]]; then 
        start $*
    elif [[ ${key} == "clean" ]]; then
        clean $* 
    else
        color_echo ${RED} "cmd wrong [install|start|clean]"
        exit 1
    fi

    return 0
}

main $*