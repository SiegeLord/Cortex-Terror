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

module game.components.Sprite;

import game.components.Drawable;
import game.components.Position;
import game.components.Orientation;
import game.IGameMode;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Bitmap;
import engine.Config;
import engine.Util;

import allegro5.allegro;

class CSprite : CDrawable
{
	this(CConfig config)
	{
		super(config);
		ShipSpriteName = config.Get!(const(char)[])("sprite", "bitmap", "");
		if(ShipSpriteName == "")
			throw new Exception("'sprite' component requires a 'bitmap' entry in the 'sprite' section of the configuration file.");
	}
	
	void LoadBitmaps(IGameMode game_mode)
	{
		ShipSprite = game_mode.BitmapManager.Load("data/bitmaps/" ~ ShipSpriteName);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "sprite", "position");
		Orientation = cast(COrientation)holder.GetComponent(COrientation.classinfo);
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto cx = ShipSprite.Width / 2;
		auto cy = ShipSprite.Height / 2;
		if(Orientation !is null)
		{
			al_draw_rotated_bitmap(ShipSprite.Get, cx, cy, Position.X, Position.Y, Orientation.Theta, 0);
		}
		else
		{
			al_draw_bitmap(ShipSprite.Get, Position.X - cx, Position.Y - cy, 0);
		}
	}
	
	mixin(Prop!("CBitmap", "ShipSprite", "", "protected"));
protected:
	const(char)[] ShipSpriteName;
	CBitmap ShipSpriteVal;
	CPosition Position;
	COrientation Orientation;
}


