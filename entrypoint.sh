#!/bin/sh

cd src
make all
mv *.elf ../build
mv *.uf2 ../build
