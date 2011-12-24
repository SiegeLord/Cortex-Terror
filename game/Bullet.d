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
