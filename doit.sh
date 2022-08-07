#!/bin/bash

# ./doit.sh clean
# ./doit.sh cod2_1_0
# ./doit.sh cod2_1_2
# ./doit.sh cod2_1_3

supported_versions="cod2_1_0 cod2_1_2 cod2_1_3"

cc="g++"
options="-I. -m32 -fPIC -Wall" # -g -ggdb -Wno-write-strings - not full warnings

# Always pick MySQL variant 1 (default)
mysql_variant=1
sed -i "/#define COMPILE_MYSQL_DEFAULT 0/c\#define COMPILE_MYSQL_DEFAULT 1" config.hpp
if [ -d "./vendors/lib" ]; then
	mysql_link="-lmysqlclient -L./vendors/lib"
	export LD_LIBRARY_PATH_32="./vendors/lib"
else
	mysql_link="-lmysqlclient -L/usr/lib/mysql"
fi

# Check if we were called with 'clean'
if [ "$1" == "clean" ]; then
	echo "##### CLEAN OBJECTS #####"
	rm objects_* -rf
	rm bin -rf
	exit 1
fi

# Check that the COD version is supported
cod_version=$1
version_supported=false
for version in $supported_versions
do
    if [[ "$cod_version" == "$version" ]]; then
        version_supported=true
        break
    fi
done

# If the COD version is not supported, stop here
if [ "$version_supported" = false ]; then
    echo -e "**** COD version not supported: $cod_version\nSupported versions are: $supported_versions"
    exit 2
fi

# Set the COD version and the appropriate defines now that we know the COD version is supported
set -- "$cod_version"
constants="-D COD_VERSION=${cod_version^^}"
if [[ "$constants" == *"COD2"* ]]; then
	constants+=" -D COD2"
fi

# Set defines based on extensions
server_ext_dir="../server-ext"
if [ -f "$server_ext_dir/functions.hpp" ]; then
	constants+=" -D SERVER_EXT_FUNCTIONS_INC"
fi

if [ -f "$server_ext_dir/config.hpp" ]; then
	constants+=" -D SERVER_EXT_CONFIG_INC"
fi

if [ -f "$server_ext_dir/includes.hpp" ]; then
	constants+=" -D SERVER_EXT_INCLUDES_INC"
fi

if [ -f "$server_ext_dir/methods.hpp" ]; then
	constants+=" -D SERVER_EXT_METHODS_INC"
fi

mkdir -p bin
mkdir -p objects_$1

echo "##### COMPILE $1 CRACKING.CPP #####"
$cc $options $constants -c cracking.cpp -o objects_$1/cracking.opp

echo "##### COMPILE $1 GSC.CPP #####"
$cc $options $constants -c gsc.cpp -o objects_$1/gsc.opp

if  grep -q "COMPILE_BOTS 1" config.hpp; then
	echo "##### COMPILE $1 GSC_BOTS.CPP #####"
	$cc $options $constants -c gsc_bots.cpp -o objects_$1/gsc_bots.opp
fi

if  grep -q "COMPILE_ENTITY 1" config.hpp; then
	echo "##### COMPILE $1 GSC_ENTITY.CPP #####"
	$cc $options $constants -c gsc_entity.cpp -o objects_$1/gsc_entity.opp
fi

if grep -q "COMPILE_EXEC 1" config.hpp; then
	echo "##### COMPILE $1 GSC_EXEC.CPP #####"
	$cc $options $constants -c gsc_exec.cpp -o objects_$1/gsc_exec.opp
fi

if grep -q "COMPILE_LEVEL 1" config.hpp; then
	echo "##### COMPILE $1 GSC_LEVEL.CPP #####"
	$cc $options $constants -c gsc_level.cpp -o objects_$1/gsc_level.opp
fi

if grep -q "COMPILE_MEMORY 1" config.hpp; then
	echo "##### COMPILE $1 GSC_MEMORY.CPP #####"
	$cc $options $constants -c gsc_memory.cpp -o objects_$1/gsc_memory.opp
fi

if [ $mysql_variant == 1 ]; then
	echo "##### COMPILE $1 GSC_MYSQL.CPP #####"
	$cc $options $constants -c gsc_mysql.cpp -o objects_$1/gsc_mysql.opp
fi

if [ $mysql_variant == 2 ]; then
	echo "##### COMPILE $1 GSC_MYSQL_VORON.CPP #####"
	$cc $options $constants -c gsc_mysql_voron.cpp -o objects_$1/gsc_mysql_voron.opp
fi

if grep -q "COMPILE_PLAYER 1" config.hpp; then
	echo "##### COMPILE $1 GSC_PLAYER.CPP #####"
	$cc $options $constants -c gsc_player.cpp -o objects_$1/gsc_player.opp
fi

if grep -q "COMPILE_UTILS 1" config.hpp; then
	echo "##### COMPILE $1 GSC_UTILS.CPP #####"
	$cc $options $constants -c gsc_utils.cpp -o objects_$1/gsc_utils.opp
fi

if grep -q "COMPILE_WEAPONS 1" config.hpp; then
	echo "##### COMPILE $1 GSC_WEAPONS.CPP #####"
	$cc $options $constants -c gsc_weapons.cpp -o objects_$1/gsc_weapons.opp
fi

if [ "$(< config.hpp grep '#define COMPILE_BSP' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 BSP.CPP #####"
	$cc $options $constants -c bsp.cpp -o objects_"$1"/bsp.opp
fi

if [ "$(< config.hpp grep '#define COMPILE_JUMP' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 JUMP.CPP #####"
	$cc $options $constants -c jump.cpp -o objects_"$1"/jump.opp
fi

echo "##### COMPILE $1 LIBCOD.CPP #####"
$cc $options $constants -c libcod.cpp -o objects_$1/libcod.opp

if [ -d $server_ext_dir ]; then
	echo "##### COMPILE $1 SERVER EXTENSIONS #####"
	cd $server_ext_dir
	for F in *.cpp;
	do
		echo "###### COMPILE $1 EXTENSION: $F #####"
		$cc $options $constants -c $F -o ../libcod/objects_$1/${F%.cpp}.opp;
	done
	cd ../libcod
fi

echo "##### LINKING lib$1.so #####"
objects="$(ls objects_$1/*.opp)"
$cc -m32 -shared -L/lib32 -o bin/lib$1.so -ldl $objects -lpthread $mysql_link
rm objects_$1 -r

if [ mysql_variant > 0 ]; then
	sed -i "/#define COMPILE_MYSQL_DEFAULT 1/c\#define COMPILE_MYSQL_DEFAULT 0" config.hpp
	sed -i "/#define COMPILE_MYSQL_VORON 1/c\#define COMPILE_MYSQL_VORON 0" config.hpp
fi

# Read leftover
rm 0
