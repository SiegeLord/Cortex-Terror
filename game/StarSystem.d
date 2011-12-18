module game.StarSystem;

import game.IGameMode;

import engine.Disposable;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.io.Stdout;
import tango.math.random.Random;

/*
 * Star class ranges from 0 (blue) to 1 (red)
 * Age ranges from 0 (all red) to 1 (all blue)
 */
ALLEGRO_COLOR GetStarColor(float star_class, float age)
{
	if(star_class < age)
		return al_map_rgb_f(star_class / age, star_class / age, 1);
	else
		return al_map_rgb_f(1, (star_class - age) / (1 - age), (star_class - age) / (1 - age));
}

class CStarSystem : CDisposable
{
	this(IGameMode game_mode, Random random, SVector2D position)
	{
		Position = position;
		GameMode = game_mode;
		Color = GetStarColor(random.uniformR2(0.0f, 1.0f), 0.9);
	}
	
	void DrawGalaxyView(float physics_alpha)
	{
		auto pos = GameMode.ToGalaxyView(Position);
		al_draw_filled_circle(pos.X, pos.Y, 10, Color);
	}

	SVector2D Position;
protected:
	IGameMode GameMode;
	ALLEGRO_COLOR Color;
}
