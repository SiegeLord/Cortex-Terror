module game.components.Star;

import game.components.Drawable;
import game.components.Position;
import game.StarSystem;

import engine.IComponentHolder;

import allegro5.allegro_primitives;

class CStar : CDrawable
{
	override
	void WireUp(IComponentHolder holder)
	{
		Position = cast(CPosition)holder.GetComponent(CPosition.classinfo);
		if(Position is null)
			throw new Exception("star component requires the position component to be present.");
	}
	
	override
	void Draw(float dt)
	{
		if(StarSystem)
		{
			al_draw_filled_circle(Position.X, Position.Y, 100, StarSystem.Color);
		}
	}
	
	CStarSystem StarSystem;
protected:
	CPosition Position;	
}

