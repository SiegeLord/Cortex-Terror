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
	
	void Damage(float damage, SColor color)
	{
		if(color == ShieldColor)
			Hitpoints -= damage;
		
		if(Hitpoints < 0)
			Hitpoints = 0;
	}
	
	SColor ShieldColor;
	float Hitpoints = 0;
	float MaxHitpoints;
}

