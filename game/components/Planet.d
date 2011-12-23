module game.components.Planet;

import game.Color;
import game.components.Updatable;
import game.components.Position;
import game.components.Orientation;
import game.components.Damageable;
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

const PopPerDamage = 10.0f;

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
		Damageable = GetComponent!(CDamageable)(holder, "planet", "damageable");
	}
	
	override
	void Update(float dt)
	{
		if(Planet)
		{
			Planet.Population = Damageable.Hitpoints * PopPerDamage;
			if(Damageable.Hitpoints < 0)
			{
				Screen.GameMode.AddBonus(Planet.Bonus);
				Planet.Bonus = EBonus.None;
			}
			
			Position = Planet.Position * ss.ConversionFactor;
			Orientation = PI + atan2(Position.Y, Position.X);
		}
	}
	
	void DrawTarget(float physics_alpha)
	{
		auto font = Screen.GameMode.UIFont;
		auto start_pos = SVector2D(Screen.GameMode.Game.Gfx.ScreenSize.X - SideBarWidth, 0);
		auto lh = 5 + font.Height;
		auto y = start_pos.Y + 10;
		
		al_draw_filled_rounded_rectangle(start_pos.X, 0, Screen.GameMode.Game.Gfx.ScreenWidth, 550, 15, 15, al_map_rgba_f(0, 0, 0, 0.5));
		
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
	
	ss.CPlanet Planet(ss.CPlanet planet)
	{
		PlanetVal = planet;
		Damageable.Hitpoints = planet.Population / PopPerDamage;
		Damageable.ShieldColor = planet.ShieldColor;
		return PlanetVal;
	}
	
	ss.CPlanet Planet()
	{
		return PlanetVal;
	}
	
	ITacticalScreen Screen;
protected:
	ss.CPlanet PlanetVal;
	CPosition Position;	
	COrientation Orientation;
	CDamageable Damageable;
}
