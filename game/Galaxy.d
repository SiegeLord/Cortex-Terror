module game.Galaxy;

import engine.Disposable;
import engine.MathTypes;

import game.StarSystem;
import game.IGameMode;
import game.Color;

import tango.math.random.Random;
import tango.math.Math;
import tango.io.Stdout;

import allegro5.allegro;

/* Needs to be greater than 6 */
const NumRaces = 40;

const ProbRed = 0.5;
const ProbGreen = 0.4;
const ProbBlue = 0.3;

const ExtraBeams = 1;

class CGalaxy : CDisposable
{
	this(IGameMode game_mode, Random random, size_t num_stars = 256, float radius = 500)
	{
		GameMode = game_mode;
		
		GameMode.RacesLeft = NumRaces;
		
		Systems.length = num_stars;
		
		foreach(ii, ref system; Systems)
		{
			SVector2D pos;
			do
			{
				pos = SVector2D(random.normalSigma(radius / 5), random.normalSigma(radius / 5));
			} while(abs(pos.X) > radius || abs(pos.Y) > radius);
			system = new CStarSystem(game_mode, random, pos);
		}
		
		size_t extra_green = 0;
		size_t extra_blue = 0;
		
		foreach(race; 0..NumRaces)
		{
			auto color = SColor(0);
			auto bonus = EBonus.None;
			
			if(race < 7)
			{
				color.ColorFlag = race + 1;
				if(race == 0)
					bonus = EBonus.GreenBeam;
				else if(race == 1)
					bonus = EBonus.BlueBeam;
			}
			else
			{
				if(random.uniformR2(0.0f, 1.0f) < ProbRed)
					color.TurnOn(EColor.Red);
				
				if(random.uniformR2(0.0f, 1.0f) < ProbBlue)
					color.TurnOn(EColor.Blue);
				
				if(random.uniformR2(0.0f, 1.0f) < ProbGreen)
					color.TurnOn(EColor.Green);
				
				if(color.ColorFlag == 0)
					color.TurnOn(EColor.Red);
				
				if(!color.Check(EColor.Green) && extra_green < ExtraBeams)
				{
					extra_green++;
					bonus = EBonus.GreenBeam;
				}
				
				if(!color.Check(EColor.Blue) && extra_blue < ExtraBeams)
				{
					extra_blue++;
					bonus = EBonus.BlueBeam;
				}
			}
					
			foreach(system; Systems)
			{
				if(system.SpawnLife(random, color, bonus))
				{
					break;
				}
			}
		}
	}
	
	override
	void Dispose()
	{
		super.Dispose();
		foreach(system; Systems)
			system.Dispose();
	}
	
	void Draw(float physics_alpha)
	{
		al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_BLEND_MODE.ALLEGRO_ONE, ALLEGRO_BLEND_MODE.ALLEGRO_ONE);
		foreach(system; Systems)
			system.DrawGalaxyView(physics_alpha);
		al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_BLEND_MODE.ALLEGRO_ONE, ALLEGRO_BLEND_MODE.ALLEGRO_INVERSE_ALPHA);
	}
	
	CStarSystem GetStarSystemAt(SVector2D position, bool delegate(CStarSystem) selector = null)
	{
		CStarSystem ret;
		auto min_dist = float.infinity;
		
		if(selector is null)
			selector = (CStarSystem sys) { return true; };
		
		foreach(system; Systems)
		{
			auto vec = system.Position - position;
			auto len_sq = vec.LengthSq;
			if(selector(system) && len_sq < min_dist)
			{
				ret = system;
				min_dist = len_sq;
			}
		}
		
		return ret;
	}
protected:
	CStarSystem[] Systems;
	IGameMode GameMode;
}
