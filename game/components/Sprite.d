module game.components.Sprite;

import game.components.Drawable;
import game.components.Position;
import game.components.Physics;
import game.components.Orientation;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Bitmap;
import engine.Config;

class CSprite : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "engine", "position");
		Orientation = cast(COrientation)holder.GetComponent(COrientation.classinfo);
	}
	
	override
	void Draw(float physics_alpha)
	{
		
	}
protected:
	CPosition Position;
	COrientation Orientation;
}


