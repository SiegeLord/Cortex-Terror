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

module game.components.Engine;

import game.components.Updatable;
import game.components.Position;
import game.components.Physics;
import game.components.Orientation;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;

class CEngine : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		Thrust = config.Get!(float)("engine", "thrust");
		Omega = config.Get!(float)("engine", "omega");
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "engine", "position");
		Physics = GetComponent!(CPhysics)(holder, "engine", "physics");
		Orientation = GetComponent!(COrientation)(holder, "engine", "orientation");
	}
	
	override
	void Update(float dt)
	{
		if(On)
		{
			auto thrust_vec = SVector2D(Thrust / Physics.Mass, 0);
			thrust_vec.Rotate(Orientation.Theta);
			Physics.Velocity += dt * thrust_vec;
		}
		if(Left)
		{
			Orientation.Theta -= dt * Omega;
		}
		if(Right)
		{
			Orientation.Theta += dt * Omega;
		}
	}
	
	bool On = false;
	bool Left = false;
	bool Right = false;
protected:
	float Thrust = 1;
	float Omega = 1;
	
	CPosition Position;
	CPhysics Physics;
	COrientation Orientation;
}


