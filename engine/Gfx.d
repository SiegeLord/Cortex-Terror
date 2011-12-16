module engine.Gfx;

import engine.Disposable;
import engine.Config;

import allegro5.allegro;
import allegro5.allegro_image;

class CGfx : CDisposable
{
	this(CConfig options)
	{
		if(options.Get!(bool)("gfx", "fullscreen", false))
			al_set_new_display_flags(ALLEGRO_FULLSCREEN_WINDOW);
		
		Display = al_create_display(options.Get!(int)("gfx", "screen_w", 800), options.Get!(int)("gfx", "screen_h", 600));
		al_init_image_addon();
	}
	
	override
	void Dispose()
	{
		super.Dispose;
	}
	
	int ScreenWidth()
	{
		return al_get_display_width(Display);
	}
	
	int ScreenHeight()
	{
		return al_get_display_height(Display);
	}
protected:
	ALLEGRO_DISPLAY* Display;
}
