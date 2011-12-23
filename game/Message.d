module game.Message;

import game.IGameMode;

import engine.Bitmap;
import engine.Gfx;

import tango.text.Util;
import tango.io.Stdout;
import tango.util.MinMax;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

const MessageTimeout = 5.0f;
const LinesPerSecond = 5.0f;

class CMessage
{
	this(IGameMode game_mode, ALLEGRO_COLOR color, const(char)[] image, const(char)[] message, bool fadeout = true, float timeout = MessageTimeout)
	{
		Color = color;
		Fadeout = fadeout;
		GameMode = game_mode;
		Message = message;
		Timeout = timeout;
		if(image !is null)
			Image = GameMode.BitmapManager.Load(image);
		CurTime = 0;
	}
	
	void Draw(float physics_alpha)
	{
		auto frac = Fadeout ? min(Timeout - CurTime, 1.0f) : 1.0f;
		
		al_draw_filled_rounded_rectangle(SideBarWidth, 0, GameMode.Game.Gfx.ScreenWidth - SideBarWidth, 200, 15, 15, 
		    Blend(al_map_rgba_f(0, 0, 0, 0), al_map_rgba_f(0, 0, 0, 0.5), frac));
		
		float extra_w = 0;
		if(Image !is null)
		{
			auto color = Blend(al_map_rgba_f(0, 0, 0, 0), al_map_rgb_f(1, 1, 1), frac);
			al_draw_tinted_bitmap(Image.Get, color, SideBarWidth + 5, 15, 0);
			extra_w = Image.Width + 5;
		}
		
		auto color = Blend(al_map_rgba_f(0, 0, 0, 0), Color, frac);
		DrawMultilineText(Message, color, SideBarWidth + extra_w + 5, GameMode.Game.Gfx.ScreenWidth - 5 - SideBarWidth, 5, CurTime * LinesPerSecond);
	}
	
	void Update(float dt)
	{
		CurTime += dt;
	}
	
	bool Done()
	{
		return CurTime >= Timeout;
	}
protected:
	void DrawMultilineText(const(char)[] text, ALLEGRO_COLOR color, float left, float right, float top, float progress)
	{
		auto cur_text = text;
		
		auto font = GameMode.UIFont.Get;
		
		auto lh = GameMode.UIFont.Height + 5;
		auto width = right - left;
		assert(width > 0);
		
		auto x = left;
		auto y = top;
		
		int line = 0;
		
		while(cur_text.length != 0)
		{
			const(char)[] cur_line;
			cur_text = cur_text.triml;
			while(true)
			{
				auto space = cur_text.locate(' ', cur_line.length + 1);
				
				bool done = false;
				if(space == cur_line.length)
					done = true;
				
				auto new_line = cur_text[0..space];
				auto ustr = const(ALLEGRO_USTR)(-1, cast(int)new_line.length, new_line.ptr);
				
				if(al_get_ustr_width(font, &ustr) > width && cur_line.length != 0)
				{
					break;
				}
				else
				{
					cur_line = new_line;
				}
				
				if(done)
					break;
			}
			
			auto ustr = const(ALLEGRO_USTR)(-1, cast(int)cur_line.length, cur_line.ptr);
			
			auto frac = progress - cast(float)line;
			frac = min(frac, 1.0f);
			
			auto final_color = Blend(al_map_rgb_f(1, 1, 1), color, frac);
			
			al_draw_ustr(font, final_color, x, y, 0, &ustr);
			y += lh;
			
			if(line >= cast(int)progress)
				break;
			
			line++;
			
			cur_text = cur_text[cur_line.length..$];
		}
	}
	
	ALLEGRO_COLOR Color;
	bool Fadeout;
	CBitmap Image;
	IGameMode GameMode;
	float CurTime;
	float Timeout;
	const(char)[] Message;
}
