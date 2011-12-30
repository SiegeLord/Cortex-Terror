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
