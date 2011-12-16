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
