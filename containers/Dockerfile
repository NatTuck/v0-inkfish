FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade
RUN apt-get -y install apt-utils debian-goodies util-linux \
    ruby python3 perl-doc libarchive-zip-perl libipc-run-perl \
    build-essential clang clang-tools valgrind gcc-multilib \
    fuse libfuse-dev pkg-config time \
    wamerican libbsd-dev libgmp-dev \
    libexpect-perl qemu-system-x86 qemu-utils

RUN adduser student --disabled-password --gecos "Student,,,,"
RUN su - student -c "curl https://sh.rustup.rs -sSf | sh -s -- -y"
