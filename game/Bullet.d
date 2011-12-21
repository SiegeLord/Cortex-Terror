module game.Bullet;

import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

const BulletSpeed = 200.0f;
const BulletLife = 3.0f;

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
		al_draw_filled_circle(Position.X, Position.Y, 5, al_map_rgb_f(1,1,1));
	}
	
	SVector2D Position;
	SVector2D Direction;
	float Life;
}
