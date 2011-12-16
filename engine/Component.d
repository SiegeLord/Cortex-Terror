module engine.Component;

import engine.Util;
import engine.IComponentHolder;

class CComponentGroup(T)
{
	void WireUp(IComponentHolder obj)
	{
		obj.GetComponent(T.classinfo, (CComponent component) { Components ~= cast(T)component; return true; });
	}
	
	void opDispatch(immutable(char)[] method_name, Args...)(Args args) 
	{
		foreach(component; Components)
		{
			mixin("component." ~ method_name ~ "(args);");
		}
	}
protected:
	T[] Components;
}

class CComponent
{
	void WireUp(IComponentHolder obj)
	{
		
	}
}
