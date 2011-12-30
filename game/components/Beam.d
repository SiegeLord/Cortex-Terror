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

module game.components.Beam;

import game.components.Drawable;
import game.components.BeamCannon;
import game.components.Position;
import game.components.Orientation;
import game.IGameMode;
import game.Color;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CBeam : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		BeamCannon = GetComponent!(CBeamCannon)(holder, "beam", "beam_cannon");
		Position = GetComponent!(CPosition)(holder, "beam", "position");
		Orientation = GetComponent!(COrientation)(holder, "beam", "orientation");
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto color = BeamCannon.ToColor();
		foreach(cannon; BeamCannon.Cannons)
		{
			if(cannon.On)
			{
				auto from = cannon.GetWorldLocation(Position.Position, Orientation.Theta);
				al_draw_line(from.X, from.Y, BeamCannon.Target.X, BeamCannon.Target.Y, color, 2);
			}
		}
	}
protected:
	CBeamCannon BeamCannon;
	CPosition Position;
	COrientation Orientation;
}
