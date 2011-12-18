module engine.Font;

import engine.Holder;

import allegro5.allegro_font;

class CFont : CHolder!(ALLEGRO_FONT*, al_destroy_font)
{
	this(ALLEGRO_FONT* font)
	{
		super(font);
	}
	
	int Height()
	{
		return al_get_font_line_height(Get);
	}
}
