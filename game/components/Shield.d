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
