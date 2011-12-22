module game.components.Shield;

import game.components.Drawable;
import game.components.Position;
import game.components.Damageable;
import game.IGameMode;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;
import engine.Gfx;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CShield : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "shield", "position");
		Damageable = GetComponent!(CDamageable)(holder, "shield", "damageable");
	}
	
	override
	void Draw(float physics_alpha)
	{
		if(Damageable.ShieldOn)
		{
			auto black = al_map_rgba_f(0, 0, 0, 0);
			auto color = Blend(black, Damageable.ShieldColor.ToColor, Damageable.ShieldTimeout);
			
			DrawCircleGradient(Position.X, Position.Y, Damageable.ShieldRadius / 2, Damageable.ShieldRadius, black, color);
			DrawCircleGradient(Position.X, Position.Y, Damageable.ShieldRadius, Damageable.ShieldRadius * 1.1, color, black);
		}
	}
protected:
	CPosition Position;
	CDamageable Damageable;
}
