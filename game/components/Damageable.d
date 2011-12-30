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
		return (Position.Position - pos).LengthSq < (CollideRadius * CollideRadius);
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

