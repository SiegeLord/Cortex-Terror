module engine.bitmapmanager;

import engine.resourcemanager;
import allegro5.allegro;
import tango.stdc.stringz;

class CBitmapManager : CResourceManager!(ALLEGRO_BITMAP*)
{
	this(CBitmapManager parent = null)
	{
		super(parent);
	}
	
	ALLEGRO_BITMAP* Load(char[] filename)
	{
		auto ret = LoadExisting(filename);
		if(ret is null)
		{
			char[256] cache;
			return Insert(filename, al_load_bitmap(toStringz(filename, cache)));
		}
		else
		{
			return ret;
		}
	}
	
protected:

	override
	void Destroy(ALLEGRO_BITMAP* bmp)
	{
		al_destroy_bitmap(bmp);
	}
}
