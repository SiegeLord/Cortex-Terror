module game.components.Controller;

import game.components.Engine;

import engine.IComponentHolder;
import engine.Component;
import engine.MathTypes;
import engine.Config;

import allegro5.allegro;

class CController : CComponent
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Engine = GetComponent!(CEngine)(holder, "controller", "engine");
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		if(event.type == ALLEGRO_EVENT_KEY_DOWN)
		{
			switch(event.keyboard.keycode)
			{
				case ALLEGRO_KEY_UP:
					Engine.On = true;
					break;
				case ALLEGRO_KEY_LEFT:
					Engine.Left = true;
					break;
				case ALLEGRO_KEY_RIGHT:
					Engine.Right = true;
					break;
				default:
			}
		}
		else if(event.type == ALLEGRO_EVENT_KEY_UP)
		{
			switch(event.keyboard.keycode)
			{
				case ALLEGRO_KEY_UP:
					Engine.On = false;
					break;
				case ALLEGRO_KEY_LEFT:
					Engine.Left = false;
					break;
				case ALLEGRO_KEY_RIGHT:
					Engine.Right = false;
					break;
				default:
			}
		}
	}
	
protected:
	CEngine Engine;
}



