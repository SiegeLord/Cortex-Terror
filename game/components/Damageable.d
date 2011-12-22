module game.components.Damageable;

import game.components.Updatable;
import game.components.Position;
import game.Color;

import engine.IComponentHolder;
import engine.Config;
import engine.Util;
import engine.MathTypes;

import tango.io.Stdout;

class CDamageable : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		MaxHitpoints = config.Get!(float)("damageable", "max_hitpoints", 100.0f);
		Mortal = config.Get!(bool)("damageable", "mortal", true);
		ShieldRadius = config.Get!(float)("damageable", "shield_radius", 60);
		CollideRadius = config.Get!(float)("damageable", "collide_radius", 32);
		Hitpoints = MaxHitpoints;
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "damageable", "position");
	}
	
	override
	void Update(float dt)
	{
		ShieldTimeout -= dt;
		if(ShieldTimeout < 0)
			ShieldOn = false;
	}
	
	void Damage(float damage, SColor color)
	{
		if(damage > 0)
		{
			if(color == ShieldColor || Hitpoints <= 0)
			{
				Hitpoints -= damage;
			}
			else
			{
				ShieldOn = true;
				ShieldTimeout = 1.0f;
			}
		}
	}
	
	bool Collide(SVector2D pos)
	{
		return (Position.Position - pos).LengthSq < (32 * 32);
	}
	
	float Health()
	{
		return Hitpoints / MaxHitpoints;
	}
	
	float ShieldTimeout = 0;
	bool ShieldOn = false;
	SColor ShieldColor;
	float Hitpoints = 0;
	float CollideRadius;
	float ShieldRadius;

	mixin(Prop!("bool", "Mortal", "", "protected"));
protected:
	bool MortalVal;
	float MaxHitpoints;
	CPosition Position;
}

