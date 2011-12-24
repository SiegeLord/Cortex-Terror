module game.Explosion;

import engine.Gfx;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

const ExplosionDuration = 0.5f;
const MinRadius = 0.2f;

struct SExplosion
{
	void Update(float dt)
	{
		Life -= dt;
	}
	
	void Draw(float physics_alpha)
	{
		auto frac = 1 - Life / ExplosionDuration;
		auto last_frac = frac < 0.5 ? 0.0f : (frac - 0.5f) / 0.5f;
		
		auto white = Blend(al_map_rgb_f(1, 1, 1), al_map_rgba_f(0, 0, 0, 0), last_frac);
		auto yellow = Blend(al_map_rgb_f(1, 1, 0), al_map_rgba_f(0, 0, 0, 0), last_frac);
		
		DrawCircleGradient(Position.X, Position.Y, 0, Scale * (frac + MinRadius), white, yellow);
		DrawCircleGradient(Position.X, Position.Y, Scale * (frac + MinRadius), Scale * (frac + 2 * MinRadius), white, al_map_rgba_f(0, 0, 0, 0));
	}
	
	void Reset(SVector2D position, float scale = 20)
	{
		Scale = scale;
		Life = ExplosionDuration;
		Position = position;
	}
	
	float Scale = 20;
	float Life = ExplosionDuration;
	SVector2D Position;
}
