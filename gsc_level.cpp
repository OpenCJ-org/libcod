#include "gsc_level.hpp"

#if COMPILE_LEVEL == 1

void gsc_level_getnumstaticmodels()
{
	stackPushInt(cm.numStaticModels);
}

void gsc_level_getstaticmodel()
{
	int index;

	if ( ! stackGetParams("i", &index))
	{
		stackError("gsc_level_getstaticmodel() argument is undefined or has a wrong type");
		stackPushUndefined();
		return;
	}

	if (index < 0 || index >= (int)cm.numStaticModels)
	{
		stackError("gsc_level_getstaticmodel() index is out of range");
		stackPushUndefined();
		return;
	}

	stackPushArray();
	stackPushString(cm.staticModelList[index].xmodel->name);
	stackPushArrayLast();
	stackPushVector(cm.staticModelList[index].origin);
	stackPushArrayLast();
}

#endif
