module game.components.Planet;

import game.components.Updatable;
import game.components.Position;
import game.components.Orientation;
import ss = game.StarSystem;
import game.ITacticalScreen;
import game.IGameMode;

import engine.IComponentHolder;
import engine.Config;
import engine.MathTypes;

import tango.io.Stdout;
import tango.math.Math;
import tango.stdc.stringz;
import tango.text.convert.Format;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

class CPlanet : CUpdatable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "planet", "position");
		Orientation = GetComponent!(COrientation)(holder, "planet", "orientation");
	}
	
	override
	void Update(float dt)
	{
		if(Planet)
		{
			Position = Planet.Position * ss.ConversionFactor;
			Orientation = PI + atan2(Position.Y, Position.X);
		}
	}
	
	
	bool Collide(SVector2D pos)
	{
		return (Position.Position - pos).LengthSq < (32 * 32);
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
		draw_line(Planet.Name, al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Class", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Planet.Class, al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Distance", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} kk", cast(int)((Position.Position - Screen.MainShipPosition).Length)), al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Population", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} M", cast(int)Planet.Population), al_map_rgb_f(0.5, 1, 0.5), true);
		
		//al_draw_filled_circle(Screen.GameMode.Game.Gfx.ScreenSize.X - SideBarWidth / 2, y + 120, 60, StarSystem.Color);
	}
	
	void Damage(float damage)
	{
		Planet.Population = Planet.Population - 10 * cast(int)damage;
		if(Planet.Population == 0)
		{
			Screen.GameMode.AddBonus(Planet.Bonus);
			Planet.Bonus = EBonus.None;
		}
	}
	
	ss.CPlanet Planet;
	ITacticalScreen Screen;
protected:
	CPosition Position;	
	COrientation Orientation;	
}

