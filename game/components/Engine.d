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
		
	}
protected:
	CPosition Position;
	CPhysics Physics;
	COrientation Orientation;
}


