
# Pull base image.
FROM buildpack-deps:bionic

RUN apt-get update \
 && apt-get install -y sudo
RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER docker

USER root
COPY install.sh .
RUN bash ./install.sh

USER root

WORKDIR /LMCAS

RUN echo "Installing WLLVM"  \
    pip3 install -U lit tabulate wllvm


COPY build-llvm.sh .
RUN bash /LMCAS/build-llvm.sh

COPY . .
RUN bash /LMCAS/build-lmcas.sh