module engine.FontManager;

import engine.ResourceManager;
import engine.Font;

import allegro5.allegro_font;

import tango.stdc.stringz;

struct SFontDesc
{
	const(char)[] Name;
	int Size;
}

class CFontManager : CResourceManager!(CFont, SFontDesc)
{
	this(CFontManager parent = null)
	{
		super(parent);
	}
	
	CFont Load(const(char)[] filename, int size)
	{
		auto desc = SFontDesc(filename, size);
		auto ret = LoadExisting(desc);
		if(ret is null)
		{
			char[256] cache;
			auto font = al_load_font(toStringz(filename, cache), size, 0);
			if(font is null)
				throw new Exception("Couldn't load '" ~ filename.idup ~ "'");
			return Insert(desc, new CFont(font));
		}
		else
		{
			return ret;
		}
	}
	
protected:

	override
	void Destroy(CFont font)
	{
		font.Dispose();
	}
}
