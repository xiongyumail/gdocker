FROM ubuntu:18.04 as essential

MAINTAINER XiongYu <xiongyu@espressif.com>

ARG UBUNTU_MIRROR=mirrors.ustc.edu.cn

# Install dependences:
RUN sed -i.bak s/archive.ubuntu.com/${UBUNTU_MIRROR}/g /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    git \
    wget \
    locales \
    dbus-x11 \
    fonts-wqy-zenhei \
    vim && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/* && \
    rm -rf /var/cache/* && \
    rm -rf /var/lib/apt/lists/*

FROM essential as install

MAINTAINER XiongYu <xiongyu@espressif.com>

ARG USER_NAME
# Make a ${USER_NAME} user
RUN adduser --disabled-password --gecos '' ${USER_NAME} && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    locale-gen zh_CN zh_CN.UTF-8  

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
ENV HOME /home/${USER_NAME}
ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8
