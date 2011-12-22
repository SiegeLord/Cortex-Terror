module game.components.Star;

import game.components.Drawable;
import game.components.Position;
import game.StarSystem;
import game.ITacticalScreen;
import game.IGameMode;

import engine.IComponentHolder;
import engine.Config;
import engine.MathTypes;
import engine.Util;
import engine.Gfx;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import tango.stdc.stringz;
import tango.io.Stdout;
import tango.text.convert.Format;

class CStar : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "star", "position");
	}
	
	override
	void Draw(float physics_alpha)
	{
		if(StarSystem)
		{
			DrawCircleGradient(Position.Position.X, Position.Position.Y, 50, StarSystem.StarRadius * 10, StarSystem.Color, al_map_rgba_f(0, 0, 0, 0));
			al_draw_filled_circle(Position.Position.X, Position.Position.Y, StarSystem.StarRadius, al_map_rgb_f(1,1,1));
		}
	}
	
	bool Collide(SVector2D pos)
	{
		if(StarSystem)
			return (Position.Position - pos).LengthSq < (StarSystem.StarRadius * StarSystem.StarRadius);
		else
			return false;
	}
	
	void DrawTarget(float physics_alpha)
	{
		auto font = Screen.GameMode.UIFont;
		auto start_pos = SVector2D(Screen.GameMode.Game.Gfx.ScreenSize.X - SideBarWidth, 0);
		auto lh = 5 + font.Height;
		auto y = start_pos.Y + 10;
		
		void draw_line(const(char)[] text, ALLEGRO_COLOR color, bool right = false)
		{
			al_draw_text(font.Get, color, right ? Screen.GameMode.Game.Gfx.ScreenSize.X - 10 : start_pos.X + 10, 
			    y, right ? ALLEGRO_ALIGN_RIGHT : ALLEGRO_ALIGN_LEFT, toStringz(text));
			y += lh;
		}
		
		draw_line("Target", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(StarSystem.Name, al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Class", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(StarSystem.Class, al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Distance", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} kk", cast(int)((Position.Position - Screen.MainShipPosition).Length)), al_map_rgb_f(0.5, 1, 0.5), true);
		
		auto cx = Screen.GameMode.Game.Gfx.ScreenSize.X - SideBarWidth / 2;
		auto cy = y + 120;
		
		DrawCircleGradient(cx, cy, 5, 60, StarSystem.Color, al_map_rgba_f(0, 0, 0, 0));
		al_draw_filled_circle(cx, cy, 10, al_map_rgb_f(1,1,1));
	}
	
	CStarSystem StarSystem;
	ITacticalScreen Screen;
protected:
	CPosition Position;	
}
