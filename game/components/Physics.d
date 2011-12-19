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
		Mass = config.Get!(float)("physics", "mass", 1);
		Friction = config.Get!(float)("physics", "friction", 0.9);
	}
	
	SVector2D Velocity;
	float Mass = 1;
	float Friction = 1;
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "physics", "position");
	}
	
	override
	void Update(float dt)
	{
		Position.Position += dt * Velocity;
		Velocity *= Friction;
	}
protected:
	CPosition Position;
}
