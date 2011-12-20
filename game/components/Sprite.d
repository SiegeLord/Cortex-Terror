module game.components.Sprite;

import game.components.Drawable;
import game.components.Position;
import game.components.Orientation;
import game.IGameMode;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Bitmap;
import engine.Config;

import allegro5.allegro;

class CSprite : CDrawable
{
	this(CConfig config)
	{
		super(config);
		ShipSpriteName = config.Get!(const(char)[])("sprite", "bitmap", "");
		if(ShipSpriteName == "")
			throw new Exception("'sprite' component requires a 'bitmap' entry in the 'sprite' section of the configuration file.");
	}
	
	void LoadBitmaps(IGameMode game_mode)
	{
		ShipSprite = game_mode.BitmapManager.Load("data/bitmaps/" ~ ShipSpriteName);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "sprite", "position");
		Orientation = cast(COrientation)holder.GetComponent(COrientation.classinfo);
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto cx = ShipSprite.Width / 2;
		auto cy = ShipSprite.Height / 2;
		if(Orientation !is null)
		{
			al_draw_rotated_bitmap(ShipSprite.Get, cx, cy, Position.X, Position.Y, Orientation.Theta, 0);
		}
		else
		{
			al_draw_bitmap(ShipSprite.Get, Position.X - cx, Position.Y - cy, 0);
		}
	}
protected:
	const(char)[] ShipSpriteName;
	CBitmap ShipSprite;
	CPosition Position;
	COrientation Orientation;
}


