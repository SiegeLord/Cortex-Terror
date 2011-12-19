module engine.Component;

import engine.Util;
import engine.Config;
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
	this(CConfig config)
	{
		
	}
	
	void WireUp(IComponentHolder obj)
	{
		
	}
	
	T GetComponent(T)(IComponentHolder obj, const(char)[] this_name, const(char)[] comp_name)
	{
		auto ret = cast(T)obj.GetComponent(T.classinfo);
		if(ret is null)
			throw new Exception("'" ~ this_name.idup ~ "' component requires the '" ~ comp_name.idup ~ "' component to be present.");
		return ret;
	}
}
