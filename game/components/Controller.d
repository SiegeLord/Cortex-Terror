module game.components.Controller;

import game.components.Engine;
import game.components.BeamCannon;
import game.components.Position;
import game.ITacticalScreen;

import engine.IComponentHolder;
import engine.Component;
import engine.MathTypes;
import engine.Config;
import engine.Util;

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
		BeamCannon = GetComponent!(CBeamCannon)(holder, "controller", "beam_cannon");
		Position = GetComponent!(CPosition)(holder, "controller", "position");
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_W:
						Engine.On = true;
						break;
					case ALLEGRO_KEY_A:
						Engine.Left = true;
						break;
					case ALLEGRO_KEY_D:
						Engine.Right = true;
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_KEY_UP:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_W:
						Engine.On = false;
						break;
					case ALLEGRO_KEY_A:
						Engine.Left = false;
						break;
					case ALLEGRO_KEY_D:
						Engine.Right = false;
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_MOUSE_AXES:
			{
				BeamCannon.ScreenTarget(SVector2D(event.mouse.x, event.mouse.y));
				
				break;
			}
			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
			{
				if(event.mouse.button == 1)
				{
					BeamCannon.On(true);
				}
				break;
			}
			case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
			{
				if(event.mouse.button == 1)
				{
					BeamCannon.On(false);
				}
				break;
			}
			default:
		}
	}
	
	mixin(Prop!("ITacticalScreen", "Screen", "", ""));
protected:
	CBeamCannon BeamCannon;
	CPosition Position;
	CEngine Engine;
	ITacticalScreen ScreenVal;
}



