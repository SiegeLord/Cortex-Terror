/*
This file is part of Cortex Terror, a game of galactic exploration and domination.
Copyright (C) 2011 Pavel Sountsov

Cortex Terror is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cortex Terror is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cortex Terror. If not, see <http:#www.gnu.org/licenses/>.
*/

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
				void play_sound()
				{
					Screen.GameMode.UISound.Play(Position.Position);
				}

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
						{
							BeamCannon.SetColor = EColor.Red;
							play_sound;
						}
						break;
					case ALLEGRO_KEY_2:
						if(Screen.GameMode.Color(EColor.Green))
						{
							BeamCannon.SetColor = EColor.Green;
							play_sound;
						}
						break;
					case ALLEGRO_KEY_3:
						if(Screen.GameMode.Color(EColor.Blue))
						{
							BeamCannon.SetColor = EColor.Blue;
							play_sound;
						}
						break;
					case ALLEGRO_KEY_4:
						if(Screen.GameMode.Color(EColor.Red) && Screen.GameMode.Color(EColor.Green))
						{
							BeamCannon.SetColor = EColor.Red | EColor.Green;
							play_sound;
						}
						break;
					case ALLEGRO_KEY_5:
						if(Screen.GameMode.Color(EColor.Red) && Screen.GameMode.Color(EColor.Blue))
						{
							BeamCannon.SetColor = EColor.Red | EColor.Blue;
							play_sound;
						}
						break;
					case ALLEGRO_KEY_6:
						if(Screen.GameMode.Color(EColor.Green) && Screen.GameMode.Color(EColor.Blue))
						{
							BeamCannon.SetColor = EColor.Green | EColor.Blue;
							play_sound;
						}
						break;
					case ALLEGRO_KEY_7:
						if(Screen.GameMode.Color(EColor.Red) && Screen.GameMode.Color(EColor.Green) && Screen.GameMode.Color(EColor.Blue))
						{
							BeamCannon.SetColor = EColor.Red | EColor.Green | EColor.Blue;
							play_sound;
						}
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



