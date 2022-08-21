#ifndef _CONFIG_HPP_
#define _CONFIG_HPP_

// GSC MODULES
#define COMPILE_BOTS 1
#define COMPILE_ENTITY 1
#define COMPILE_EXEC 1
#define COMPILE_LEVEL 1
#define COMPILE_MEMORY 1
#define COMPILE_MYSQL 0
#define COMPILE_PLAYER 1
#define COMPILE_SQLITE 0
#define COMPILE_UTILS 1
#define COMPILE_WEAPONS 1

// EXPERIMENTAL FEATURES
#define COMPILE_BSP 0
#define COMPILE_JUMP 1

// RATE LIMITER
#define COMPILE_RATELIMITER 1

// EXTRA STUFF
#ifdef SERVER_EXT_CONFIG_INC
#include "../server-ext//config.hpp"
#endif

#endif
