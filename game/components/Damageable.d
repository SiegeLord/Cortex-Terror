module game.components.Damageable;

import game.components.Updatable;
import game.Color;

import engine.IComponentHolder;
import engine.Config;
import engine.Util;

import tango.io.Stdout;

class CDamageable : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		MaxHitpoints = config.Get!(float)("damageable", "max_hitpoints", 100.0f);
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
		if(color == ShieldColor || Hitpoints == 0)
		{
			Hitpoints -= damage;
		}
		else
		{
			ShieldOn = true;
			ShieldTimeout = 0.5;
		}
	}
	
	float ShieldTimeout = 0;
	bool ShieldOn = false;
	SColor ShieldColor;
	float Hitpoints = 0;
	float MaxHitpoints;
}

