module game.components.Engine;

import game.components.Updatable;
import game.components.Position;
import game.components.Physics;
import game.components.Orientation;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;

class CEngine : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		Thrust = config.Get!(float)("engine", "thrust");
		Omega = config.Get!(float)("engine", "omega");
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "engine", "position");
		Physics = GetComponent!(CPhysics)(holder, "engine", "physics");
		Orientation = GetComponent!(COrientation)(holder, "engine", "orientation");
	}
	
	override
	void Update(float dt)
	{
		if(On)
		{
			auto thrust_vec = SVector2D(Thrust / Physics.Mass, 0);
			thrust_vec.Rotate(Orientation.Theta);
			Physics.Velocity += dt * thrust_vec;
		}
		if(Left)
		{
			Orientation.Theta -= dt * Omega;
		}
		if(Right)
		{
			Orientation.Theta += dt * Omega;
		}
	}
	
	bool On = false;
	bool Left = false;
	bool Right = false;
protected:
	float Thrust = 1;
	float Omega = 1;
	
	CPosition Position;
	CPhysics Physics;
	COrientation Orientation;
}


