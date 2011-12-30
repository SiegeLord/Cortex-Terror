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

module engine.SoundManager;

import engine.ResourceManager;
import engine.Sound;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_audio;

import tango.stdc.stringz;

class CSoundManager : CResourceManager!(CSound)
{
	this(CSoundManager parent = null)
	{
		super(parent);
	}
	
	CSound Load(const(char)[] filename)
	{
		auto ret = LoadExisting(filename);
		if(ret is null)
		{
			char[256] cache;
			auto snd = al_load_sample(toStringz(filename, cache));
			if(snd is null)
				throw new Exception("Couldn't load '" ~ filename.idup ~ "'");
			return Insert(filename, new CSound(snd));
		}
		else
		{
			return ret;
		}
	}
	
	void Update(float dt, SVector2D center)
	{
		foreach(snd; Cache)
			snd.Update(dt, center);
	}
	
protected:

	override
	void Destroy(CSound snd)
	{
		snd.Dispose();
	}
}
