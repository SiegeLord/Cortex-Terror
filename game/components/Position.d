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
	
	SVector2D Position;
}
