module game.StarSystem;

import game.IGameMode;
import game.RandomName;

import engine.Disposable;
import engine.MathTypes;
import engine.Util;
import engine.Bitmap;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import tango.io.Stdout;
import tango.math.random.Random;
import tango.math.Math;
import tango.core.Array;
import tango.stdc.stringz;
import tango.text.convert.Format;

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

/* Scales the star_class so that the return ranges from 0 to 1, with 0.5 being white, 0 being blue and 1 being red*/
float GetStarClass(float star_class, float age)
{
	if(star_class < age)
		return star_class / age * 0.5;
	else
		return (star_class - age) / (1 - age) * 0.5 + 0.5;
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
	
	void DrawPreview(float physics_alpha, float cx, float cy)
	{
		al_draw_circle(cx, cy, MinorAxis, al_map_rgb_f(1, 1, 1), 1);
		al_draw_filled_circle(cx, cy + MinorAxis, 10, al_map_rgb_f(1, 0.5, 0.5));
	}
	
	float Population()
	{
		return PopulationVal;
	}
	
	float Population(float new_pop)
	{
		if(new_pop < 0)
			new_pop = 0;
		
		return PopulationVal = new_pop;
	}
	
	const(char)[] Name;
	const(char)[] Class = "M";
protected:
	size_t Orbit;
	IGameMode GameMode;
	float PeriastronTheta = 0;
	float MinorAxis = 100;
	float MajorAxis = 100;
	float PeriodOffset = 0;
	float PopulationVal = 0;
}

const MinRadius = 50.0f;
const MaxRadius = 200.0f;
const MaxPlanets = 5;
const ConversionFactor = 40; // Ratio of tactical units to star system units
const UniAge = 0.5;
const BaseLifeProbability = 0.25;
const MaxPlanetPopulation = 40000;

class CStarSystem : CDisposable
{
	this(IGameMode game_mode, Random random, SVector2D position)
	{
		SmallStarSprite = game_mode.BitmapManager.Load("data/bitmaps/star_small.png");
		SmallStarHaloSprite = game_mode.BitmapManager.Load("data/bitmaps/star_halo_small.png");

		Position = position;
		GameMode = game_mode;
		auto r = random.uniformR2(0.0f, 1.0f);
		
		auto classes = ["O", "B", "A", "F", "G", "K", "M", "L", "T"];
		ClassFraction = GetStarClass(r, UniAge) / 1.0001;
		Class = classes[cast(size_t)(ClassFraction * classes.length)];
		
		Brightness = r - UniAge;
		if(Brightness > 0)
			Brightness /= (1.0 - UniAge);
		else
			Brightness /= UniAge;
		Brightness = exp(2 * (2 - Brightness) - 1);
		Color = GetStarColor(r, UniAge);
		Planets.length = random.uniformR2(0, cast(int)MaxPlanets);
		Name = GenerateRandomName(random);
		
		size_t[MaxPlanets] orbits;
		foreach(ii, ref orbit; orbits)
			orbit = ii;
		
		orbits[].shuffle((size_t n) { return random.uniformR2(cast(size_t)0, n); });
				
		foreach(ii, ref planet; Planets)
		{
			planet = new CPlanet(GameMode, random, orbits[ii]);
		}
		
		sort(Planets, (CPlanet a, CPlanet b) { return a.Orbit < b.Orbit; });
		
		auto roman_numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
		
		foreach(ii, planet; Planets)
		{
			planet.Name = Name ~ " " ~ roman_numerals[ii];
		}
	}
	
	bool SpawnLife(Random random)
	{
		if(HaveLifeforms)
			return false;
		
		auto habitable_orbit = (1 - ClassFraction) * (MaxPlanets - 1);
		
		foreach(planet; Planets)
		{
			auto prob = BaseLifeProbability / (abs(planet.Orbit - habitable_orbit) + 1);
			if(random.uniformR2(0.0f, 1.0f) < prob)
			{
				planet.Population = random.exp!(float)() * MaxPlanetPopulation;
			}
		}
		
		return HaveLifeforms;
	}
	
	bool HaveLifeforms()
	{
		foreach(planet; Planets)
		{
			if(planet.Population > 0)
				return true;
		}
		return false;
	}
	
	void DrawGalaxyView(float physics_alpha)
	{
		auto pos = GameMode.ToGalaxyView(Position);
		auto col = Explored ? Color : al_map_rgb_f(0.5, 0.5, 0.5);
		//al_draw_filled_circle(pos.X, pos.Y, 10, col);
		if(Explored)
		{
			al_draw_tinted_bitmap(SmallStarHaloSprite.Get, col, pos.X - SmallStarHaloSprite.Width / 2, pos.Y - SmallStarHaloSprite.Height / 2, 0);
			if(HaveLifeforms)
			{
				auto tri_rad = 20;
				auto vtx = SVector2D(tri_rad, 0);
				vtx.Rotate(PI / 6);
				al_draw_triangle(pos.X, pos.Y - tri_rad, pos.X - vtx.X, pos.Y + vtx.Y, pos.X + vtx.X, pos.Y + vtx.Y, al_map_rgb_f(1, 0, 0), 2);
			}
		}
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
	
	void DrawPreview(float physics_alpha)
	{
		auto font = GameMode.UIFont;
		auto bar_left = GameMode.Game.Gfx.ScreenSize.X - SideBarWidth;
		auto bar_right = GameMode.Game.Gfx.ScreenSize.X;
		auto lh = 5 + font.Height;
		auto y = 10;
		
		void draw_line(const(char)[] text, ALLEGRO_COLOR color, bool right = false)
		{
			al_draw_text(font.Get, color, right ? bar_right - 10 : bar_left + 10, 
			    y, right ? ALLEGRO_ALIGN_RIGHT : ALLEGRO_ALIGN_LEFT, toStringz(text));
			y += lh;
		}
		
		draw_line("Target", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Name, al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Class", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Class, al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Lifeforms", al_map_rgb_f(0.5, 0.5, 1));
		if(HaveLifeforms)
			draw_line("Present", al_map_rgb_f(1, 0, 0), true);
		else
			draw_line("None", al_map_rgb_f(0.5, 1, 0.5), true);
		draw_line("Distance", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} Tk", cast(int)((Position - GameMode.GalaxyLocation).Length)), al_map_rgb_f(0.5, 1, 0.5), true);
		
		auto x = GameMode.Game.Gfx.ScreenSize.X - SideBarWidth / 2;
		y += 40;
		
		al_draw_filled_circle(x, y, 20, Color);
		
		al_set_clipping_rectangle(cast(int)bar_left, y, cast(int)bar_right, GameMode.Game.Gfx.ScreenHeight - y);
		
		foreach(planet; Planets)
		{
			planet.DrawPreview(physics_alpha, x, y);
		}
		
		al_set_clipping_rectangle(0, 0, GameMode.Game.Gfx.ScreenWidth, GameMode.Game.Gfx.ScreenHeight);
	}
	
	float EnergyFlux(float distance)
	{
		if(distance < 100)
			distance = 100;
		return Brightness * 1e3f / (distance * distance);
	}

	mixin(Prop!("const(char)[]", "Name", "", "protected"));
	mixin(Prop!("ALLEGRO_COLOR", "Color", "", "protected"));
	mixin(Prop!("const(char)[]", "Class", "", "protected"));

	SVector2D Position;
	bool Explored = false;
	CPlanet[] Planets;
protected:
	float ClassFraction;
	const(char)[] ClassVal;
	float Brightness = 1;
	CBitmap SmallStarSprite;
	CBitmap SmallStarHaloSprite;
	const(char)[] NameVal;
	IGameMode GameMode;
	ALLEGRO_COLOR ColorVal;
}
