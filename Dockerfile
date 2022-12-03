FROM ubuntu:20.04 as build
CMD bash

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
	git \
	build-essential \
	gdb-multiarch \
	qemu-system-misc \
	gcc-riscv64-linux-gnu \
	binutils-riscv64-linux-gnu