module game.Galaxy;

import engine.Disposable;
import engine.MathTypes;

import game.StarSystem;
import game.IGameMode;

import tango.math.random.Random;
import tango.math.Math;
import tango.io.Stdout;

import allegro5.allegro;

class CGalaxy : CDisposable
{
	this(IGameMode game_mode, Random random, size_t num_stars = 256, float radius = 500)
	{
		GameMode = game_mode;
		
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
