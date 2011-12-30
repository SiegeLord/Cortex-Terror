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

module engine.ResourceManager;

import engine.Disposable;

class CResourceManager(T, Key=char[]) : CDisposable
{
	this(CResourceManager!(T, Key) parent = null)
	{
		Parent = parent;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		
		foreach(entry; Cache)
			Destroy(entry);
		
		Cache = null;
	}
	
protected:

	T LoadExisting(const(Key) name)
	{
		T ret;
		auto ptr = name in Cache;
		if(ptr is null)
		{
			if(Parent !is null)
				ret = Parent.LoadExisting(name);
			else
				return null;
		}
		else
		{
			ret = *ptr;
		}
		return ret;
	}

	void Destroy(T entry)
	{
		
	}
	
	T Default()
	{
		return null;
	}
	
	T Insert(const(Key) key, T entry)
	{
		if(entry is null)
		{
			//ERROR of some sort
			return Default;
		}
		else
		{
			Cache[key] = entry;
			return entry;
		}
	}
	
	T[Key] Cache;
	CResourceManager!(T, Key) Parent;
}
