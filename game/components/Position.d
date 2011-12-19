module game.components.Position;

import engine.Component;
import engine.MathTypes;
import engine.Config;

class CPosition : CComponent
{
	this(CConfig config)
	{
		super(config);
	}
	
	alias Position this;
	
	SVector2D Position;
}
