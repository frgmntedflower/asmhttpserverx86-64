#!/bin/bash
set -e

mkdir -p build

nasm -f elf64 src/server.s -o build/server.o
ld build/server.o -o build/server

./build/server
