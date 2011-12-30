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
			al_set_new_bitmap_flags(ALLEGRO_MAG_LINEAR | ALLEGRO_MIN_LINEAR);
			auto bmp = al_load_bitmap(toStringz(filename, cache));
			al_set_new_bitmap_flags(ALLEGRO_VIDEO_BITMAP);
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
