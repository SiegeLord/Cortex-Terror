module engine.Sfx;

import engine.Disposable;

import allegro5.allegro;
import allegro5.allegro_audio;
import allegro5.allegro_acodec;

import tango.io.Stdout;

class CSfx : CDisposable
{
	this()
	{
		al_install_audio();
		al_init_acodec_addon();
		al_reserve_samples(1);
	}
	
	override
	void Dispose()
	{
		super.Dispose;
	}
}
