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

module game.components.Rectangle;

import game.components.Position;
import game.components.Drawable;

import engine.IComponentHolder;
import engine.Config;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CRectangle : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto pos = Position.Position;
		al_draw_filled_rectangle(pos.X, pos.Y, pos.X + 100, pos.Y + 100, al_map_rgb_f(1, 0, 1));
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "rectangle", "position");
	}
	
protected:
	CPosition Position;
}
