module game.components.Orientation;

import engine.Component;
import engine.Config;

class COrientation : CComponent
{
	this(CConfig config)
	{
		super(config);
	}
	
	void Set(float theta)
	{
		Theta = theta;
	}
	
	float Theta = 0;
	alias Theta this;
}
