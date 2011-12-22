module game.components.Controller;

import game.components.Engine;
import game.components.BeamCannon;
import game.components.Position;
import game.ITacticalScreen;
import game.IGameMode;
import game.Color;

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
					case ALLEGRO_KEY_1:
						if(Screen.GameMode.Color(EColor.Red))
							BeamCannon.SetColor = EColor.Red;
						break;
					case ALLEGRO_KEY_2:
						if(Screen.GameMode.Color(EColor.Green))
							BeamCannon.SetColor = EColor.Green;
						break;
					case ALLEGRO_KEY_3:
						if(Screen.GameMode.Color(EColor.Blue))
							BeamCannon.SetColor = EColor.Blue;
						break;
					case ALLEGRO_KEY_4:
						if(Screen.GameMode.Color(EColor.Red) && Screen.GameMode.Color(EColor.Green))
							BeamCannon.SetColor = EColor.Red | EColor.Green;
						break;
					case ALLEGRO_KEY_5:
						if(Screen.GameMode.Color(EColor.Red) && Screen.GameMode.Color(EColor.Blue))
							BeamCannon.SetColor = EColor.Red | EColor.Blue;
						break;
					case ALLEGRO_KEY_6:
						if(Screen.GameMode.Color(EColor.Green) && Screen.GameMode.Color(EColor.Blue))
							BeamCannon.SetColor = EColor.Green | EColor.Blue;
						break;
					case ALLEGRO_KEY_7:
						if(Screen.GameMode.Color(EColor.Red) && Screen.GameMode.Color(EColor.Green) && Screen.GameMode.Color(EColor.Blue))
							BeamCannon.SetColor = EColor.Red | EColor.Green | EColor.Blue;
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



