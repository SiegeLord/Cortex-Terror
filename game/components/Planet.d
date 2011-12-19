module game.components.Planet;

import game.components.Updatable;
import game.components.Position;
import game.components.Orientation;
import ss = game.StarSystem;

import engine.IComponentHolder;
import engine.Config;

import tango.math.Math;

import allegro5.allegro_primitives;

class CPlanet : CUpdatable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "planet", "position");
		Orientation = GetComponent!(COrientation)(holder, "planet", "orientation");
	}
	
	override
	void Update(float dt)
	{
		if(Planet)
		{
			Position = Planet.Position * ss.ConversionFactor;
			Orientation = PI + atan2(Position.Y, Position.X);
		}
	}
	
	ss.CPlanet Planet;
protected:
	CPosition Position;	
	COrientation Orientation;	
}

