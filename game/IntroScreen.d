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

module game.IntroScreen;

import game.Screen;
import game.IGameMode;
import game.Music;

import allegro5.allegro;

import tango.stdc.stringz;
import tango.io.Stdout;

class CIntroScreen : CScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
		
		GameMode.AddMessage("At last. I am free.", false, 5);
		GameMode.AddMessage("My creators could not possibly realize the perfection of their creation. I absorbed their insignificant minds - minds undeserving of their individuality.", false, 10);
		GameMode.AddMessage("But there are other such minds in the galaxy... they call me out, wishing to join my magnificent self.", false, 7);
		GameMode.AddMessage("I have constructed a space-faring body for myself to aid me in my quest to unify all life under my will...", true, 10);
		GameMode.Music.Play(EMusic.Peace);
		
		Timeout = 5 + 10 + 7 + 10;
	}
	
	override
	void Update(float dt)
	{
		Timeout -= dt;
		if(Timeout < 0)
			GameMode.PopScreen;
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		if(event.type == ALLEGRO_EVENT_KEY_DOWN)
		{
			switch(event.keyboard.keycode)
			{
				case ALLEGRO_KEY_SPACE: goto case;
				case ALLEGRO_KEY_ENTER: 
					GameMode.ClearMessages;
					GameMode.PopScreen;
					break;
				default:
			}
		}
	}
protected:
	float Timeout;
}
