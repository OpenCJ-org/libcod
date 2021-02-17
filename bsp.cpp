#include "bsp.hpp"

#if COMPILE_BSP == 1

void BSP_DecompileMap_f()
{
	if (!scrVarPub.developer)
	{
		printf("BSP_DecompileMap: developer mode needs to be enabled for decompilation.\n");
		return;
	}

	Com_DPrintf("BSP_DecompileMap: mapname: %s\n", cm.name);
}

void BSP_AddCommand()
{
	Cmd_AddCommand("map_decompile", BSP_DecompileMap_f);
}

#endif
