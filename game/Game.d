module game.Game;

import engine.BitmapManager;
import engine.Gfx;
import engine.Disposable;
import engine.Config;

import tango.io.Stdout;

import allegro5.allegro;

class CGame : CDisposable
{
	this()
	{
		al_init();
		Options = new CConfig("game.cfg");
		Gfx = new CGfx(Options);
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		
		Gfx.Dispose;
		Options.Dispose;
	}
	
	void Run()
	{
		
	}
protected:
	CConfig Options;
	CGfx Gfx;
}
