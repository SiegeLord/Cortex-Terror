module game.components.Physics;

import game.components.Updatable;
import game.components.Position;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;

class CPhysics : CUpdatable
{
	this(CConfig config)
	{
		super(config);
	}
	
	SVector2D Velocity;
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "physics", "position");
	}
	
	override
	void Update(float dt)
	{
		Position.Position += dt * Velocity;
	}
protected:
	CPosition Position;
}

