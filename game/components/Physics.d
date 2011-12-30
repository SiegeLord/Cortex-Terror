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

module game.components.Physics;

import game.components.Updatable;
import game.components.Position;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;

class CPhysics : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		Mass = config.Get!(float)("physics", "mass", 1);
		Friction = config.Get!(float)("physics", "friction", 0.9);
	}
	
	SVector2D Velocity;
	float Mass = 1;
	float Friction = 1;
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "physics", "position");
	}
	
	override
	void Update(float dt)
	{
		Position.Position += dt * Velocity;
		Velocity *= Friction;
	}
protected:
	CPosition Position;
}
