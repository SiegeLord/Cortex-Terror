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

module engine.Gfx;

import engine.Disposable;
import engine.Config;
import engine.Util;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.math.Math;

class CGfx : CDisposable
{
	this(CConfig options)
	{
		if(options.Get!(bool)("gfx", "fullscreen", false))
			al_set_new_display_flags(ALLEGRO_FULLSCREEN_WINDOW);
		
		al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_SAMPLE_BUFFERS, 1, ALLEGRO_SUGGEST);
		al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_SAMPLES, 4, ALLEGRO_SUGGEST);
		
		Display = al_create_display(options.Get!(int)("gfx", "screen_w", 800), options.Get!(int)("gfx", "screen_h", 600));
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
	
	SVector2D ScreenSize()
	{
		return SVector2D(ScreenWidth, ScreenHeight);
	}
	
	void ResetTransform()
	{
		ALLEGRO_TRANSFORM identity;
		al_identity_transform(&identity);
		al_use_transform(&identity);
	}
	
	mixin(Prop!("ALLEGRO_DISPLAY*", "Display", "", "protected"));
protected:
	ALLEGRO_DISPLAY* DisplayVal;
}

void DrawCircleGradient(float cx, float cy, float r1, float r2, ALLEGRO_COLOR color1, ALLEGRO_COLOR color2)
{
	assert(r2 > r1);
	
	auto r = (r2 + r1) / 2;
	auto t = r2 - r1;
	
	ALLEGRO_VERTEX[100] vtx;
	auto num_segments = vtx.length / 2;

	al_calculate_arc(&(vtx[0].x), ALLEGRO_VERTEX.sizeof, cx, cy, r, r, 0, PI * 2, t, cast(int)(num_segments));
	foreach(ii; 0..2 * num_segments)
	{
		vtx[ii].color = ii % 2 ? color1 : color2;
		vtx[ii].z = 0;
	}

	al_draw_prim(vtx.ptr, null, null, 0, cast(int)(2 * num_segments), ALLEGRO_PRIM_TYPE.ALLEGRO_PRIM_TRIANGLE_STRIP);
}

ALLEGRO_COLOR Blend(ALLEGRO_COLOR c1, ALLEGRO_COLOR c2, float frac)
{
	return al_map_rgba_f(c1.r + (c2.r - c1.r) * frac, 
	                     c1.g + (c2.g - c1.g) * frac, 
	                     c1.b + (c2.b - c1.b) * frac, 
	                     c1.a + (c2.a - c1.a) * frac);
}
