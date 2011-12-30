/*
This file is part of Cortex Terror, a game of galactic exploration and domination.
Copyright (C) 2011 Pavel Sountsov

Cortex Terror is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cortex Terror is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cortex Terror. If not, see <http:#www.gnu.org/licenses/>.
*/

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
			
			if(Damageable.ShieldColor.ColorFlag == 0)
				Damageable.ShieldColor = SColor(1);
		}
	}
	
protected:
	float RotateTime = 0;
	float RotateDuration;
	CDamageable Damageable;
}
