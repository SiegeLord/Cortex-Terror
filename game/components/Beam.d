module game.components.Beam;

import game.components.Drawable;
import game.components.BeamCannon;
import game.components.Position;
import game.components.Orientation;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CBeam : CDrawable
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		BeamCannon = GetComponent!(CBeamCannon)(holder, "beam", "beam_cannon");
		Position = GetComponent!(CPosition)(holder, "beam", "position");
		Orientation = GetComponent!(COrientation)(holder, "beam", "orientation");
	}
	
	override
	void Draw(float physics_alpha)
	{
		foreach(cannon; BeamCannon.Cannons)
		{
			if(cannon.On)
			{
				auto from = cannon.GetWorldLocation(Position.Position, Orientation.Theta);
				al_draw_line(from.X, from.Y, BeamCannon.Target.X, BeamCannon.Target.Y, al_map_rgb_f(1, 1, 0), 2);
			}
		}
	}
protected:
	CBeamCannon BeamCannon;
	CPosition Position;
	COrientation Orientation;
}
