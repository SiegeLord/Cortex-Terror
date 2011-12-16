module game.components.Rectangle;

import game.components.Position;
import game.components.Drawable;
import engine.IComponentHolder;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CRectangle : CDrawable
{
	override
	void Draw(float physics_alpha)
	{
		al_draw_filled_rectangle(Position.X, Position.Y, Position.X + 100, Position.Y + 100, al_map_rgb_f(1, 0, 1));
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = cast(CPosition)holder.GetComponent(CPosition.classinfo);
		if(Position is null)
			throw new Exception("physics component requires the position component to be present.");
	}
	
protected:
	CPosition Position;
}
