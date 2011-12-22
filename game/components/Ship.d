module game.components.Ship;

import engine.IComponentHolder;
import engine.Config;
import engine.Component;
import engine.MathTypes;

import game.components.Sprite;
import game.components.Damageable;
import game.components.Physics;
import game.components.Position;
import game.ITacticalScreen;
import game.IGameMode;

import tango.io.Stdout;
import tango.math.Math;
import tango.stdc.stringz;
import tango.text.convert.Format;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

class CShip : CComponent
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Damageable = GetComponent!(CDamageable)(holder, "ship", "damageable");
		Physics = GetComponent!(CPhysics)(holder, "ship", "physics");
		Position = GetComponent!(CPosition)(holder, "ship", "position");
		Sprite = GetComponent!(CSprite)(holder, "ship", "sprite");
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
		draw_line("Enemy Ship", al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Mass", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} Kt", Physics.Mass), al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Health", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{}%", cast(int)(100 * Damageable.Health)), al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Distance", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} kk", cast(int)((Position.Position - Screen.MainShipPosition).Length)), al_map_rgb_f(0.5, 1, 0.5), true);
		
		auto cx = Screen.GameMode.Game.Gfx.ScreenSize.X - SideBarWidth / 2;
		auto cy = y + 120;
		
		auto bmp = Sprite.ShipSprite;
		
		al_draw_rotated_bitmap(bmp.Get, bmp.Width / 2, bmp.Height / 2, cx, cy, -PI / 2, 0);
	}
	
	ITacticalScreen Screen;
protected:
	CPosition Position;
	CPhysics Physics;
	CDamageable Damageable;
	CSprite Sprite;
}
