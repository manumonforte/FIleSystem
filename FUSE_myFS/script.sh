#!/bin/bash

#set -xv



#varibles para guardar rutas
src="/src"
v_mount="/mount-point"
cd src
file1="myFS.h"
file2="fuseLib.c"
file3="MyFileSystem.c"
cd ..

#crea tmp
rm -rf tmp
mkdir tmp

temp="/tmp"

#si existe disco lo desmonta y se crea
#./createDisk.sh

#copiamos a tmp
cp $(pwd)$src/$file1 $(pwd)$temp/copy_myFS.h
cp $(pwd)$src/$file2 $(pwd)$temp/copy_fuseLib.c
echo "ficheros copiados a tmp"

#copiamos ficheros a SF 
cp $(pwd)$src/$file1 $(pwd)$v_mount/copy_myFS.h
cp $(pwd)$src/$file2 $(pwd)$v_mount/copy_fuseLib.c
echo "ficheros copiados a mount"

#Auditamos disco
../my-fsck/my-fsck ../FUSE_myFS/virtual-disk

#Realizamos diff
result1=$(diff $(pwd)$v_mount/copy_myFS.h $(pwd)$temp/copy_myFS.h)
result2=$(diff $(pwd)$v_mount/copy_fuseLib.c $(pwd)$temp/copy_fuseLib.c)

if [[ "$result1"=="" && "$result2"=="" ]]
then
  echo "los ficheros son iguales"
  echo "Correct"
  else
  echo "los ficheros tienen contenidos diferentes"
fi

#truncamos los ficheros
truncate -o -s -1 $(pwd)$v_mount/copy_myFS.h
truncate -o -s -1 $(pwd)$temp/copy_myFS.h

#auditamos disco
../my-fsck/my-fsck ../FUSE_myFS/virtual-disk

#Realizamos diff
result3=$(diff $(pwd)$src/$file1 $(pwd)$v_mount/copy_myFS.h)
result4=$(diff $(pwd)$src/$file1 $(pwd)$temp/copy_myFS.h)

if [[ "$result3"=="" && "$result4"=="" ]]
then
  echo "ficheros truncados iguales que el  original"
  echo "Correct"
  else
  echo "ficheros truncados diferentes del original"
fi

cp $(pwd)$src/$file3 $(pwd)$v_mount/copy_MyFS.c

#auditamos disco
../my-fsck/my-fsck ../FUSE_myFS/virtual-disk

#comparamos original y SF
result5=$(diff $(pwd)$src/$file3 $(pwd)$v_mount/copy_MyFS.c)

if [[ "$result5"=="" ]]
then
  echo "fichero3 igual que el original"
  echo "Correct"
  else
  echo "fichero3 diferents del original"
fi

#truncamos el fichero2
truncate -o -s +3 $(pwd)$v_mount/copy_fuseLib.c
truncate -o -s +3 $(pwd)$temp/copy_fuseLib.c

#auditamos disco
../my-fsck/my-fsck ../FUSE_myFS/virtual-disk
#hacer diff entre truncado y original
result6=$(diff $(pwd)$src/$file2 $(pwd)$v_mount/copy_fuseLib.c)
result7=$(diff $(pwd)$src/$file2 $(pwd)$temp/copy_fuseLib.c)

if [[ "$result6"=="" && "$result7"="" ]]
then
  echo "fichero2 igual que el original"
  echo "Correct"
  else
  echo "fichero2 diferents del original"
fi

