module game.components.Star;

import game.components.Drawable;
import game.components.Position;
import game.StarSystem;

import engine.IComponentHolder;
import engine.Config;

import allegro5.allegro_primitives;

class CStar : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "star", "position");
	}
	
	override
	void Draw(float dt)
	{
		if(StarSystem)
		{
			al_draw_filled_circle(Position.Position.X, Position.Position.Y, 100, StarSystem.Color);
		}
	}
	
	CStarSystem StarSystem;
protected:
	CPosition Position;	
}

