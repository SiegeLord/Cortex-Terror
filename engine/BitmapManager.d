module engine.BitmapManager;

import engine.ResourceManager;
import engine.Bitmap;

import allegro5.allegro;

import tango.stdc.stringz;

class CBitmapManager : CResourceManager!(CBitmap)
{
	this(CBitmapManager parent = null)
	{
		super(parent);
	}
	
	CBitmap Load(const(char)[] filename)
	{
		auto ret = LoadExisting(filename);
		if(ret is null)
		{
			char[256] cache;
			return Insert(filename, new CBitmap(al_load_bitmap(toStringz(filename, cache))));
		}
		else
		{
			return ret;
		}
	}
	
protected:

	override
	void Destroy(CBitmap bmp)
	{
		bmp.Dispose();
	}
}
