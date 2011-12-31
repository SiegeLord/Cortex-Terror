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

module game.StarSystem;

import game.IGameMode;
import game.RandomName;
import game.Color;

import engine.Disposable;
import engine.MathTypes;
import engine.Util;
import engine.Bitmap;
import engine.Gfx;
import engine.Config;

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
 * Star fraction ranges from 0 (blue) to 1 (red)
 * Age ranges from 0 (all red) to 1 (all blue)
 */
ALLEGRO_COLOR GetStarColor(float star_fraction, float age)
{
	if(star_fraction < age)
		return al_map_rgb_f(star_fraction / age, star_fraction / age, 1);
	else
		return al_map_rgb_f(1, 1 - (star_fraction - age) / (1.0f - age), 1 - (star_fraction - age) / (1 - age));
}

/* Scales the star_class so that the return ranges from 0 to 1, with 0.5 being white, 0 being blue and 1 being red*/
float GetStarClass(float star_fraction, float age)
{
	if(star_fraction < age)
		return star_fraction / age * 0.5;
	else
		return (star_fraction - age) / (1.0f - age) * 0.5 + 0.5;
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
		
		LoadPlanetIcon;
		
		auto r = random.uniformR2(0, 120);
		switch(r)
		{
			case 0: .. case 3:
				Bonus = EBonus.Health;
				break;
			case 10: .. case 13:
				Bonus = EBonus.Energy;
				break;
			case 50:
				Bonus = EBonus.RedBeam;
				break;
			case 51:
				Bonus = EBonus.GreenBeam;
				break;
			case 52:
				Bonus = EBonus.BlueBeam;
				break;
			default:
		}
	}
	
	SVector2D Position()
	{
		auto e = sqrt(1.0f - (MinorAxis * MinorAxis / MajorAxis / MajorAxis));
		auto period = MajorAxis * 100;
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
		//al_draw_filled_circle(pos.X, pos.Y, 10, al_map_rgba_f(0.5, 0.25, 0.25, 0.5));
		
		auto x_scale = 20.0f / PlanetIcon.Width;
		auto y_scale = 20.0f / PlanetIcon.Height;
		
		al_draw_tinted_scaled_rotated_bitmap(PlanetIcon.Get, al_map_rgba_f(0.5, 0.5, 0.5, 0.5), PlanetIcon.Width / 2, PlanetIcon.Height / 2,
		    pos.X, pos.Y, x_scale, y_scale, PI + atan2(pos.Y, pos.X), 0);
	}
	
	void DrawPreview(float physics_alpha, float cx, float cy)
	{
		al_draw_circle(cx, cy, MinorAxis, al_map_rgb_f(1, 1, 1), 1);
		//al_draw_filled_circle(cx, cy + MinorAxis, 10, al_map_rgb_f(1, 0.5, 0.5));
		
		auto x_scale = 20.0f / PlanetIcon.Width;
		auto y_scale = 20.0f / PlanetIcon.Height;
		
		al_draw_scaled_rotated_bitmap(PlanetIcon.Get, PlanetIcon.Width / 2, PlanetIcon.Height / 2, cx, cy + MinorAxis, x_scale, y_scale, -PI / 2, 0);
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
	
	void LoadPlanetIcon()
	{
		const(char)[] image = Class == "M" ? "data/bitmaps/planet2.png" : "data/bitmaps/planet1.png";
		PlanetIcon = GameMode.BitmapManager.Load(image);
	}
	
	const(char)[] Name;
	const(char)[] Class = "G";
	EBonus Bonus = EBonus.None;
	SColor ShieldColor;
protected:
	CBitmap PlanetIcon;
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
const MeanPlanetPopulation = 15000;

class CStarSystem : CDisposable
{
	this(IGameMode game_mode, Random random, SVector2D position, size_t index)
	{
		Index = index;
		
		SmallStarSprite = game_mode.BitmapManager.Load("data/bitmaps/star_small.png");
		SmallStarHaloSprite = game_mode.BitmapManager.Load("data/bitmaps/star_halo_small.png");

		Position = position;
		GameMode = game_mode;
		auto r = random.uniformR2(0.0f, 1.0f);
		
		auto classes = ["O", "B", "A", "F", "G", "K", "M", "L", "T"];
		ClassFraction = GetStarClass(r, UniAge) / 1.0001;
		Class = classes[cast(size_t)(ClassFraction * classes.length)];
		Brightness = exp(2.0f * (1.0f - ClassFraction));
		Color = GetStarColor(r, UniAge);
		Planets.length = random.uniformR2(0, cast(int)MaxPlanets);
		Name = GenerateRandomName(random);
		StarRadiusVal = random.uniformR2(100, 200);
		
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
	
	bool SpawnLife(Random random, SColor color, EBonus bonus)
	{
		if(HaveLifeforms)
			return false;
		
		auto habitable_orbit = (1 - ClassFraction) * (MaxPlanets - 1);
		
		bool bonus_given = false;
		
		foreach(planet; Planets)
		{
			auto prob = BaseLifeProbability / (abs(planet.Orbit - habitable_orbit) + 1);
			if(random.uniformR2(0.0f, 1.0f) < prob)
			{
				planet.Population = MeanPlanetPopulation + random.exp!(float)() * MeanPlanetPopulation;
				planet.Class = "M";
				planet.LoadPlanetIcon;
				planet.ShieldColor = color;
				ShieldColor = color;
				if(!bonus_given && bonus != EBonus.None)
				{
					planet.Bonus = bonus;
					bonus_given = true;
				}
			}
			else
			{
				planet.Class = "G";
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
	
	bool HaveArtifacts()
	{
		foreach(planet; Planets)
		{
			if(planet.Bonus != EBonus.None)
				return true;
		}
		return false;
	}
	
	void DrawGalaxyView(float physics_alpha)
	{
		auto pos = GameMode.ToGalaxyView(Position);
		auto col = Scanned ? Color : al_map_rgb_f(0.5, 0.5, 0.5);
		//al_draw_filled_circle(pos.X, pos.Y, 10, col);
		if(Scanned)
		{
			al_draw_tinted_bitmap(SmallStarHaloSprite.Get, col, pos.X - SmallStarHaloSprite.Width / 2, pos.Y - SmallStarHaloSprite.Height / 2, 0);
			if(HaveLifeforms)
			{
				auto color = Visited ? ShieldColor.ToColor : al_map_rgb_f(0.5, 0.5, 0.5);
				auto tri_rad = 20;
				auto vtx = SVector2D(tri_rad, 0);
				vtx.Rotate(PI / 6);
				al_draw_triangle(pos.X, pos.Y - tri_rad, pos.X - vtx.X, pos.Y + vtx.Y, pos.X + vtx.X, pos.Y + vtx.Y, color, 2);
			}
			else if(Visited && HaveArtifacts)
			{
				al_draw_rectangle(pos.X - 20, pos.Y - 20, pos.X + 20, pos.Y + 20, al_map_rgb_f(0, 0, 1), 2);
			}
		}
		al_draw_bitmap(SmallStarSprite.Get, pos.X - SmallStarSprite.Width / 2, pos.Y - SmallStarSprite.Height / 2, 0);
	}
	
	void DrawSystemView(float physics_alpha)
	{
		DrawCircleGradient(0, 0, 5, 30, Blend(Color, al_map_rgba_f(0, 0, 0, 0), 0.25), al_map_rgba_f(0, 0, 0, 0));
		DrawCircleGradient(0, 0, 0, 5, al_map_rgba_f(0.75, 0.75, 0.75, 0.75), al_map_rgba_f(0.75, 0.75, 0.75, 0.75));
		
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
		
		draw_line("Artifacts", al_map_rgb_f(0.5, 0.5, 1));
		if(!Visited)
		{
			draw_line("Unknown", al_map_rgb_f(0.5, 1, 0.5), true);
		}
		else
		{
			if(HaveArtifacts)
				draw_line("Present", al_map_rgb_f(1, 0, 0), true);
			else
				draw_line("None", al_map_rgb_f(0.5, 1, 0.5), true);
		}
		
		draw_line("Distance", al_map_rgb_f(0.5, 0.5, 1));
		draw_line(Format("{} Tk", cast(int)((Position - GameMode.GalaxyLocation).Length)), al_map_rgb_f(0.5, 1, 0.5), true);
		
		auto x = GameMode.Game.Gfx.ScreenSize.X - SideBarWidth / 2;
		y += 40;
		
		DrawCircleGradient(x, y, 5, 30, Blend(Color, al_map_rgba_f(0, 0, 0, 0), 0.25), al_map_rgba_f(0, 0, 0, 0));
		DrawCircleGradient(x, y, 0, 5, al_map_rgb_f(1, 1, 1), al_map_rgb_f(1, 1, 1));
		
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
		return Brightness * 1e2f / (distance);
	}

	mixin(Prop!("const(char)[]", "Name", "", "protected"));
	mixin(Prop!("ALLEGRO_COLOR", "Color", "", "protected"));
	mixin(Prop!("const(char)[]", "Class", "", "protected"));
	mixin(Prop!("float", "StarRadius", "", "protected"));
	mixin(Prop!("size_t", "Index", "", "protected"));
	
	void Save(CConfig config)
	{
		auto section_name = Format("{}", Index);
		config.Set(section_name, "visited", Visited);
		config.Set(section_name, "scanned", Scanned);
		
		foreach(ii, planet; Planets)
		{
			config.Set(section_name, Format("population_{}", ii), planet.Population);
			config.Set(section_name, Format("bonus_{}", ii), planet.Bonus);
		}
	}
	
	void Load(CConfig config)
	{
		auto section_name = Format("{}", Index);
		Visited = config.Get!(bool)(section_name, "visited", false);
		Scanned = config.Get!(bool)(section_name, "scanned", false);
		
		foreach(ii, planet; Planets)
		{
			planet.Population = config.Get!(float)(section_name, Format("population_{}", ii), 0);
			planet.Bonus = cast(EBonus)config.Get!(int)(section_name, Format("bonus_{}", ii), EBonus.None);
		}
	}

	SVector2D Position;
	bool Scanned = false;
	bool Visited = false;
	CPlanet[] Planets;
protected:
	size_t IndexVal;
	float StarRadiusVal;
	SColor ShieldColor;
	float ClassFraction;
	const(char)[] ClassVal;
	float Brightness = 1;
	CBitmap SmallStarSprite;
	CBitmap SmallStarHaloSprite;
	const(char)[] NameVal;
	IGameMode GameMode;
	ALLEGRO_COLOR ColorVal;
}
