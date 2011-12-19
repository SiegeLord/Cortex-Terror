module game.components.Rectangle;

import game.components.Position;
import game.components.Drawable;

import engine.IComponentHolder;
import engine.Config;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CRectangle : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto pos = Position.Position;
		al_draw_filled_rectangle(pos.X, pos.Y, pos.X + 100, pos.Y + 100, al_map_rgb_f(1, 0, 1));
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "rectangle", "position");
	}
	
protected:
	CPosition Position;
}
