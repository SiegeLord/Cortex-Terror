module game.Galaxy;

import engine.Disposable;
import engine.MathTypes;

import game.StarSystem;
import game.IGameMode;

import tango.math.random.Random;
import tango.math.Math;
import tango.io.Stdout;

class CGalaxy : CDisposable
{
	this(IGameMode game_mode, uint seed, size_t num_stars = 256, float radius = 500)
	{
		GameMode = game_mode;
		Rand = new Random;
		Rand.seed({ return seed; });
		
		Systems.length = num_stars;
		
		foreach(ii, ref system; Systems)
		{
			SVector2D pos;
			do
			{
				pos = SVector2D(Rand.normalSigma(radius / 5), Rand.normalSigma(radius / 5));
			} while(abs(pos.X) > radius || abs(pos.Y) > radius);
			system = new CStarSystem(game_mode, Rand, pos);
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
		foreach(system; Systems)
			system.DrawGalaxyView(physics_alpha);
	}
	
	CStarSystem GetStarSystemAt(SVector2D position)
	{
		CStarSystem ret;
		auto min_dist = float.infinity;
		
		foreach(system; Systems)
		{
			auto vec = system.Position - position;
			auto len_sq = vec.LengthSq;
			if(len_sq < min_dist)
			{
				ret = system;
				min_dist = len_sq;
			}
		}
		
		return ret;
	}
protected:
	Random Rand;
	CStarSystem[] Systems;
	IGameMode GameMode;
}
