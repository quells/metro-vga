#!/bin/sh

cd src
make all dump
mv *.elf ../build
mv *.uf2 ../build
