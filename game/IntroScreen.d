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
