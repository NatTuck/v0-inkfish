FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y upgrade
RUN apt-get -y install apt-utils debian-goodies util-linux \
    ruby python3 perl-doc libarchive-zip-perl libipc-run-perl \
    build-essential clang clang-tools valgrind \
    fuse libfuse-dev pkg-config \
    wamerican libbsd-dev libgmp-dev

RUN adduser student --disabled-password --gecos "Student,,,,"
