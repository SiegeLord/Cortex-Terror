/*
This file is part of Cortex Terror, a game of galactic exploration and domination.
Copyright (C) 2011 Pavel Sountsov

Cortex Terror is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cortex Terror is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cortex Terror. If not, see <http:#www.gnu.org/licenses/>.
*/

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
	
	struct SDispatchHelper(ComponentType)
	{
		CComponentHolder Holder;
		
		void opDispatch(immutable(char)[] method_name, Args...)(Args args)
		{
			Holder.GetComponent(ComponentType.classinfo, (CComponent comp) { mixin("(cast(ComponentType)comp)." ~ method_name ~ "(args);"); return true; });
		}
	}
	
	SDispatchHelper!(ComponentType) Select(ComponentType)()
	{
		return SDispatchHelper!(ComponentType)(this);
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
