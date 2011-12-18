module game.StarSystem;

import game.IGameMode;

import engine.Disposable;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.io.Stdout;
import tango.math.random.Random;
import tango.math.Math;
import tango.core.Array;

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

class CPlanet
{
	this(IGameMode game_mode, Random random, float minor_axis)
	{
		GameMode = game_mode;
		PeriastronTheta = random.uniformR2(-PI, PI);
		MinorAxis = minor_axis;
		MajorAxis = minor_axis * random.uniformR2(1.0f, 1.002f);
		PeriodOffset = random.uniformR2(0.0f, 1.0f);
	}
	
	SVector2D Position()
	{
		auto e = sqrt(1.0f - (MinorAxis * MinorAxis / MajorAxis / MajorAxis));
		auto period = MajorAxis * 10;
		auto theta = (GameMode.Game.Time / period + PeriodOffset) * 2 * PI + PeriastronTheta;
		auto r = MajorAxis * (1.0f - e * e) / (1 - e * cos(theta));
		auto ret = SVector2D(r, 0);
		
		ret.Rotate(theta);
		return ret;
	}
	
	void DrawSystemView(float physics_alpha)
	{
		ALLEGRO_TRANSFORM current_transform;
		al_copy_transform(&current_transform, al_get_current_transform());
		ALLEGRO_TRANSFORM orbit_transform;
		al_identity_transform(&orbit_transform);
		al_rotate_transform(&orbit_transform, PeriastronTheta);
		al_compose_transform(&orbit_transform, &current_transform);
		al_use_transform(&orbit_transform);
		
		al_draw_ellipse(sqrt(MajorAxis * MajorAxis - MinorAxis * MinorAxis), 0, MajorAxis, MinorAxis, al_map_rgb_f(1,1,1), 1);
		
		auto pos = Position();
		
		al_draw_filled_circle(pos.X, pos.Y, 10, al_map_rgb_f(1, 0.5, 0.5));
		
		al_use_transform(&current_transform);
	}
protected:
	IGameMode GameMode;
	float PeriastronTheta = 0;
	float MinorAxis = 100;
	float MajorAxis = 100;
	float PeriodOffset = 0;
}

const MinRadius = 50.0f;
const MaxRadius = 200.0f;
const MaxPlanets = 5;

class CStarSystem : CDisposable
{
	this(IGameMode game_mode, Random random, SVector2D position)
	{
		Position = position;
		GameMode = game_mode;
		Color = GetStarColor(random.uniformR2(0.0f, 1.0f), 0.9);
		Planets.length = random.uniformR2(1, cast(int)MaxPlanets);
		
		size_t[MaxPlanets] orbits;
		foreach(ii, ref orbit; orbits)
			orbit = ii;
		
		orbits[].shuffle((size_t n) { return random.uniformR2(cast(size_t)0, n); });
				
		foreach(ii, ref planet; Planets)
		{
			planet = new CPlanet(GameMode, random, MaxRadius * orbits[ii] / MaxPlanets + MinRadius);
		}
	}
	
	void DrawGalaxyView(float physics_alpha)
	{
		auto pos = GameMode.ToGalaxyView(Position);
		al_draw_filled_circle(pos.X, pos.Y, 10, Color);
	}
	
	void DrawSystemView(float physics_alpha)
	{
		al_draw_filled_circle(0, 0, 20, Color);
		foreach(planet; Planets)
		{
			planet.DrawSystemView(physics_alpha);
		}
	}

	SVector2D Position;
protected:
	CPlanet[] Planets;
	IGameMode GameMode;
	ALLEGRO_COLOR Color;
}
