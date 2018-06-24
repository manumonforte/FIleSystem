#!/bin/bash

rm -rf /mount-point
fusermount -u mount-point
mkdir mount-point
make #generamos fs-fuse
./fs-fuse -t 2097152 -a virtual-disk -f '-s -d mount-point'
