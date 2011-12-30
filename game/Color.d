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

module game.Color;

import allegro5.allegro;

enum EColor : int
{
	Red = 1,
	Green = 2,
	Blue = 4
}

struct SColor
{
	const
	bool Check(int color)
	{
		return (ColorFlag & color) == color;
	}
	
	bool Toggle(EColor color)
	{
		ColorFlag ^= color;
		if(ColorFlag == 0)
			ColorFlag |= color;
		
		return Check(color);
	}
	
	void TurnOn(EColor color)
	{
		ColorFlag |= color;
	}
	
	const
	ALLEGRO_COLOR ToColor()
	{
		auto color = al_map_rgb_f(0, 0, 0);
		if(Check(EColor.Red))
			color.r = 1;
		if(Check(EColor.Green))
			color.g = 1;
		if(Check(EColor.Blue))
			color.b = 1;
		return color;
	}
	
	const
	bool opEquals(SColor other)
	{
		return other.ColorFlag == ColorFlag;
	}
	
	int ColorFlag = EColor.Red;
}
