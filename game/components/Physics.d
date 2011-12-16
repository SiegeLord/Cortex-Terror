module game.components.Physics;

import game.components.Updatable;
import game.components.Position;

import engine.IComponentHolder;

class CPhysics : CUpdatable
{
	float Vx, Vy;
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = cast(CPosition)holder.GetComponent(CPosition.classinfo);
		if(Position is null)
			throw new Exception("physics component requires the position component to be present.");
	}
	
	override
	void Update(float dt)
	{
		Position.X += dt * Vx;
		Position.Y += dt * Vy;
	}
protected:
	CPosition Position;
}

