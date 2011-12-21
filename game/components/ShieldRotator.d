module game.components.ShieldRotator;

import game.components.Updatable;
import game.components.Damageable;
import game.Color;

import engine.IComponentHolder;
import engine.Component;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import allegro5.allegro;

import tango.io.Stdout;
import tango.math.random.Random;

class CShieldRotator : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		RotateDuration = config.Get!(float)("shield_rotator", "duration", 2);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Damageable = GetComponent!(CDamageable)(holder, "shield_rotator", "damageable");
	}
	
	override
	void Update(float dt)
	{
		RotateTime -= dt;
		if(RotateTime < 0)
		{
			Damageable.ShieldColor = SColor(0);
			RotateTime = RotateDuration;
			if(rand.uniformR(1.0f) < 0.5)
				Damageable.ShieldColor.TurnOn(EColor.Red);
			if(rand.uniformR(1.0f) < 0.5)
				Damageable.ShieldColor.TurnOn(EColor.Blue);
			if(rand.uniformR(1.0f) < 0.5)
				Damageable.ShieldColor.TurnOn(EColor.Green);
		}
	}
	
protected:
	float RotateTime = 0;
	float RotateDuration;
	CDamageable Damageable;
}
