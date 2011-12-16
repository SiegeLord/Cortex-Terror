module engine.Bitmap;

import engine.Holder;

import allegro5.allegro;

class CBitmap : CHolder!(ALLEGRO_BITMAP*, al_destroy_bitmap)
{
	this(ALLEGRO_BITMAP* bmp)
	{
		super(bmp);
	}
	
	int W()
	{
		return al_get_bitmap_width(Get);
	}
	
	int H()
	{
		return al_get_bitmap_height(Get);
	}
}
