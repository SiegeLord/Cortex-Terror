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
