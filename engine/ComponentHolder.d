module engine.ComponentHolder;

import engine.IComponentHolder;
import engine.Component;
import engine.Util;
import engine.Config;
import engine.Disposable;

class CComponentHolder : CDisposable, IComponentHolder
{
	void AddComponent(CComponent component)
	{
		ComponentsVal ~= component;
	}
	
	void WireUp()
	{
		foreach(component; Components)
			component.WireUp(this);
	}
	
	void opDispatch(immutable(char)[] method_name, ComponentType, Args...)(Args args)
	{
		GetComponent(ComponentType.classinfo, (CComponent comp) { mixin("(cast(ComponentType)comp)." ~ method_name ~ "(args);"); return true; });
	}
	
	override
	void GetComponent(ClassInfo type, bool delegate(CComponent comp) callback)
	{
		foreach(component; Components)
		{
			//component a subclass of type
			auto base = component.classinfo;
			while(base !is null)
			{
				if(base is type)
				{
					if(!callback(component))
						return;
				}
				
				base = base.base;
			}
		}
	}
	
	override
	CComponent GetComponent(ClassInfo type)
	{
		CComponent ret;
		GetComponent(type, (CComponent comp){ret = comp; return false;});
		return ret;
	}
	
	mixin(Prop!("const(char)[]", "Name", "override", "protected"));
	
	override
	CComponent[] Components()
	{
		return ComponentsVal;
	}
protected:
	const(char)[] NameVal;
	CComponent[] ComponentsVal;
}
