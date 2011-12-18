module engine.Gfx;

import engine.Disposable;
import engine.Config;
import engine.Util;

import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_primitives;

class CGfx : CDisposable
{
	this(CConfig options)
	{
		if(options.Get!(bool)("gfx", "fullscreen", false))
			al_set_new_display_flags(ALLEGRO_FULLSCREEN_WINDOW);
		
		al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_SAMPLE_BUFFERS, 1, ALLEGRO_SUGGEST);
		al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_SAMPLES, 4, ALLEGRO_SUGGEST);
		
		Display = al_create_display(options.Get!(int)("gfx", "screen_w", 800), options.Get!(int)("gfx", "screen_h", 600));
		al_init_image_addon();
		al_init_primitives_addon();
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
	
	mixin(Prop!("ALLEGRO_DISPLAY*", "Display", "", "protected"));
protected:
	ALLEGRO_DISPLAY* DisplayVal;
}
