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
