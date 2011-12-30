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

module game.Bullet;

import engine.MathTypes;
import engine.Gfx;

import allegro5.allegro;
import allegro5.allegro_primitives;

const BulletSpeed = 500.0f;
const BulletLife = 2.0f;

struct SBullet
{
	void Launch(SVector2D position, SVector2D direction)
	{
		Life = BulletLife;
		Position = position;
		Direction = direction;
	}
	
	void Update(float dt)
	{
		Position += BulletSpeed * Direction * dt;
		Life -= dt;
	}
	
	void Draw(float physics_alpha)
	{
		DrawCircleGradient(Position.X, Position.Y, 0, 10, al_map_rgb_f(0,0,1), al_map_rgba_f(0, 0, 0, 0));
		al_draw_filled_circle(Position.X, Position.Y, 5, al_map_rgb_f(1,1,1));
	}
	
	SVector2D Position;
	SVector2D Direction;
	float Life;
}
