module game.StarSystem;

import game.IGameMode;
import game.RandomName;

import engine.Disposable;
import engine.MathTypes;
import engine.Util;
import engine.Bitmap;

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
	this(IGameMode game_mode, Random random, size_t orbit)
	{
		GameMode = game_mode;
		Orbit = orbit;
		PeriastronTheta = random.uniformR2(-PI, PI);
		MinorAxis = MaxRadius * Orbit / MaxPlanets + MinRadius;
		MajorAxis = MinorAxis * random.uniformR2(1.0f, 1.002f);
		PeriodOffset = random.uniformR2(0.0f, 1.0f);
	}
	
	SVector2D Position()
	{
		auto e = sqrt(1.0f - (MinorAxis * MinorAxis / MajorAxis / MajorAxis));
		auto period = MajorAxis * 10;
		auto theta = (GameMode.Game.Time / period + PeriodOffset) * 2 * PI;
		auto r = MajorAxis * (1.0f - e * e) / (1 - e * cos(PI + theta + PeriastronTheta));
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
		al_rotate_transform(&orbit_transform, PI - PeriastronTheta);
		al_compose_transform(&orbit_transform, &current_transform);
		al_use_transform(&orbit_transform);
		
		al_draw_ellipse(sqrt(MajorAxis * MajorAxis - MinorAxis * MinorAxis), 0, MajorAxis, MinorAxis, al_map_rgba_f(0.5,0.5,0.5,0.5), 1);
		
		al_use_transform(&current_transform);
		
		auto pos = Position();
		al_draw_filled_circle(pos.X, pos.Y, 10, al_map_rgba_f(0.5, 0.25, 0.25, 0.5));
	}
	
	void DrawPreview(float physics_alpha)
	{
		al_draw_circle(0, 0, MinorAxis, al_map_rgb_f(1, 1, 1), 1);
		al_draw_filled_circle(0, MinorAxis, 10, al_map_rgb_f(1, 0.5, 0.5));
	}
protected:
	size_t Orbit;
	IGameMode GameMode;
	float PeriastronTheta = 0;
	float MinorAxis = 100;
	float MajorAxis = 100;
	float PeriodOffset = 0;
}

const MinRadius = 50.0f;
const MaxRadius = 200.0f;
const MaxPlanets = 5;
const ConversionFactor = 40; // Ratio of tactical units to star system units

class CStarSystem : CDisposable
{
	this(IGameMode game_mode, Random random, SVector2D position)
	{
		SmallStarSprite = game_mode.BitmapManager.Load("data/bitmaps/star_small.png");
		SmallStarHaloSprite = game_mode.BitmapManager.Load("data/bitmaps/star_halo_small.png");

		Position = position;
		GameMode = game_mode;
		Color = GetStarColor(random.uniformR2(0.0f, 1.0f), 0.5);
		Planets.length = random.uniformR2(1, cast(int)MaxPlanets);
		Name = GenerateRandomName(random);
		
		size_t[MaxPlanets] orbits;
		foreach(ii, ref orbit; orbits)
			orbit = ii;
		
		orbits[].shuffle((size_t n) { return random.uniformR2(cast(size_t)0, n); });
				
		foreach(ii, ref planet; Planets)
		{
			planet = new CPlanet(GameMode, random, orbits[ii]);
		}
	}
	
	void DrawGalaxyView(float physics_alpha)
	{
		auto pos = GameMode.ToGalaxyView(Position);
		auto col = Explored ? Color : al_map_rgb_f(0.5, 0.5, 0.5);
		//al_draw_filled_circle(pos.X, pos.Y, 10, col);
		if(Explored)
			al_draw_tinted_bitmap(SmallStarHaloSprite.Get, col, pos.X - SmallStarHaloSprite.Width / 2, pos.Y - SmallStarHaloSprite.Height / 2, 0);
		al_draw_bitmap(SmallStarSprite.Get, pos.X - SmallStarSprite.Width / 2, pos.Y - SmallStarSprite.Height / 2, 0);
	}
	
	void DrawSystemView(float physics_alpha)
	{
		al_draw_filled_circle(0, 0, 20, Color);
		foreach(planet; Planets)
		{
			planet.DrawSystemView(physics_alpha);
		}
	}
	
	void DrawPreview(float physics_alpha, int bar_left, int bar_right)
	{
		al_draw_filled_circle(0, 0, 20, Color);
		
		auto clip_h = GameMode.Game.Gfx.ScreenHeight / 2;
		
		al_set_clipping_rectangle(bar_left, clip_h, bar_right, clip_h);
		
		foreach(planet; Planets)
		{
			planet.DrawPreview(physics_alpha);
		}
		
		al_set_clipping_rectangle(0, 0, GameMode.Game.Gfx.ScreenWidth, GameMode.Game.Gfx.ScreenHeight);
	}
	
	float EnergyFlux(float distance)
	{
		if(distance < 100)
			distance = 100;
		return 5e4f / (distance * distance);
	}

	mixin(Prop!("const(char)[]", "Name", "", "protected"));
	mixin(Prop!("ALLEGRO_COLOR", "Color", "", "protected"));

	SVector2D Position;
	bool Explored = false;
	CPlanet[] Planets;
protected:
	CBitmap SmallStarSprite;
	CBitmap SmallStarHaloSprite;
	const(char)[] NameVal;
	IGameMode GameMode;
	ALLEGRO_COLOR ColorVal;
}
