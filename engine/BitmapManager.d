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
			auto bmp = al_load_bitmap(toStringz(filename, cache));
			if(bmp is null)
				throw new Exception("Couldn't load '" ~ filename.idup ~ "'");
			return Insert(filename, new CBitmap(bmp));
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
