module game.components.Shield;

import game.components.Drawable;
import game.components.Position;
import game.components.Damageable;
import game.IGameMode;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;

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
			al_draw_circle(Position.X, Position.Y, 100, Damageable.ShieldColor.ToColor, 2);
		}
	}
protected:
	CPosition Position;
	CDamageable Damageable;
}



