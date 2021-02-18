#!/bin/bash

# ./doit.sh clean
# ./doit.sh cod2_1_0
# ./doit.sh cod2_1_2
# ./doit.sh cod2_1_3

cc="g++"
options="-I. -m32 -fPIC -Wall"

mysql_found=0
mysql_link=""

sqlite_found=0
sqlite_link=""

mysql_libpath="/usr/lib32/libmysqlclient.so"
mysql_libpath2="/usr/lib/i386-linux-gnu/libmysqlclient.so"
mysql_libpath3="/usr/lib/libmysqlclient.so"

sqlite_libpath="/usr/lib32/libsqlite3.so"
sqlite_libpath2="/usr/lib/i386-linux-gnu/libsqlite3.so"
sqlite_libpath3="/usr/lib/libsqlite3.so"

pthread_link=""

if [ "$1" != "clean" ]; then
	if [ -e "$mysql_libpath" ] || [ -e "$mysql_libpath2" ] || [ -e "$mysql_libpath3" ]; then
		mysql_found=1
		mysql_link="-lmysqlclient -L/usr/lib/mysql"
	elif [ -d "./vendors/lib" ]; then
		export LD_LIBRARY_PATH_32="./vendors/lib"
		mysql_found=1
		mysql_link="-lmysqlclient -L./vendors/lib"
	else
		sed -i "/#define COMPILE_MYSQL 1/c\\#define COMPILE_MYSQL 0" config.hpp
	fi

	if [ -e "$sqlite_libpath" ] || [ -e "$sqlite_libpath2" ] || [ -e "$sqlite_libpath3" ]; then
		sqlite_found=1
		sqlite_link="-lsqlite3"
	else
		sed -i "/#define COMPILE_SQLITE 1/c\\#define COMPILE_SQLITE 0" config.hpp
	fi
fi

if [ "$1" == "clean" ]; then
	echo "##### CLEAN OBJECTS #####"
	rm objects_* -rf
	rm bin -rf
	exit 1

elif [ "$1" == "cod2_1_0" ]; then
	constants="-D COD_VERSION=COD2_1_0"

elif [ "$1" == "cod2_1_2" ]; then
	constants="-D COD_VERSION=COD2_1_2"

elif [ "$1" == "cod2_1_3" ]; then
	constants="-D COD_VERSION=COD2_1_3"

elif [ "$1" == "" ]; then
	echo "##### Please specify a command line option #####"
	exit 0

else
	echo "##### Unrecognized command line option $1 #####"
	exit 0
fi

if [ -f extra/functions.hpp ]; then
	constants+=" -D EXTRA_FUNCTIONS_INC"
fi

if [ -f extra/config.hpp ]; then
	constants+=" -D EXTRA_CONFIG_INC"
fi

if [ -f extra/includes.hpp ]; then
	constants+=" -D EXTRA_INCLUDES_INC"
fi

if [ -f extra/methods.hpp ]; then
	constants+=" -D EXTRA_METHODS_INC"
fi

mkdir -p bin
mkdir -p objects_"$1"

echo "##### COMPILE $1 CRACKING.CPP #####"
$cc $options $constants -c cracking.cpp -o objects_"$1"/cracking.opp

echo "##### COMPILE $1 GSC.CPP #####"
$cc $options $constants -c gsc.cpp -o objects_"$1"/gsc.opp

if [ "$(< config.hpp grep '#define COMPILE_BOTS' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_BOTS.CPP #####"
	$cc $options $constants -c gsc_bots.cpp -o objects_"$1"/gsc_bots.opp
fi

if [ "$(< config.hpp grep '#define COMPILE_ENTITY' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_ENTITY.CPP #####"
	$cc $options $constants -c gsc_entity.cpp -o objects_"$1"/gsc_entity.opp
fi

if [ "$(< config.hpp grep '#define COMPILE_EXEC' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_EXEC.CPP #####"
	$cc $options $constants -c gsc_exec.cpp -o objects_"$1"/gsc_exec.opp
	pthread_link="-lpthread"
fi

if [ "$(< config.hpp grep '#define COMPILE_LEVEL' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_LEVEL.CPP #####"
	$cc $options $constants -c gsc_level.cpp -o objects_"$1"/gsc_level.opp
fi

if [ "$(< config.hpp grep '#define COMPILE_MEMORY' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_MEMORY.CPP #####"
	$cc $options $constants -c gsc_memory.cpp -o objects_"$1"/gsc_memory.opp
fi

if [ $mysql_found -eq 1 ]; then
	if [ "$(< config.hpp grep '#define COMPILE_MYSQL' | grep -o '[0-9]')" == "1" ]; then
		echo "##### COMPILE $1 GSC_MYSQL.CPP #####"
		$cc $options $constants -c gsc_mysql.cpp -o objects_"$1"/gsc_mysql.opp
		pthread_link="-lpthread"
	fi
else
	echo "##### WARNING: MySQL lib not found, MySQL compilation skipped #####"
fi

if [ "$(< config.hpp grep '#define COMPILE_PLAYER' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_PLAYER.CPP #####"
	$cc $options $constants -c gsc_player.cpp -o objects_"$1"/gsc_player.opp
fi

if [ $sqlite_found -eq 1 ]; then
	if [ "$(< config.hpp grep '#define COMPILE_SQLITE' | grep -o '[0-9]')" == "1" ]; then
		echo "##### COMPILE $1 GSC_SQLITE.CPP #####"
		$cc $options $constants -c gsc_sqlite.cpp -o objects_"$1"/gsc_sqlite.opp
		pthread_link="-lpthread"
	fi
else
	echo "##### WARNING: SQLite lib not found, SQLite compilation skipped #####"
fi

if [ "$(< config.hpp grep '#define COMPILE_UTILS' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_UTILS.CPP #####"
	$cc $options $constants -c gsc_utils.cpp -o objects_"$1"/gsc_utils.opp
fi

if [ "$(< config.hpp grep '#define COMPILE_WEAPONS' | grep -o '[0-9]')" == "1" ]; then
	echo "##### COMPILE $1 GSC_WEAPONS.CPP #####"
	$cc $options $constants -c gsc_weapons.cpp -o objects_"$1"/gsc_weapons.opp
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
$cc $options $constants -c libcod.cpp -o objects_"$1"/libcod.opp

if [ -d extra ]; then
	echo "##### COMPILE $1 EXTRAS #####"
	(
	cd extra || return
	for F in *.cpp;
	do
		echo "###### COMPILE $1 EXTRA: $F #####"
		$cc $options $constants -c "$F" -o ../objects_"$1"/"${F%.cpp}".opp;
	done
	)
fi

echo "##### LINKING lib$1.so #####"
objects="$(ls objects_$1/*.opp)"
$cc -m32 -shared -L/lib32 -o bin/lib"$1".so -ldl $objects $pthread_link $mysql_link $sqlite_link
rm objects_"$1" -r

if [ $mysql_found -eq 0 ]; then
	sed -i "/#define COMPILE_MYSQL 0/c\\#define COMPILE_MYSQL 1" config.hpp
fi

if [ $sqlite_found -eq 0 ]; then
	sed -i "/#define COMPILE_SQLITE 0/c\\#define COMPILE_SQLITE 1" config.hpp
fi
