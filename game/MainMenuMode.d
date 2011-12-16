module game.MainMenuMode;

import game.Mode;
import game.IGame;

import allegro5.allegro;

import tango.io.Stdout;

class CMainMenuMode : CMode
{
	this(IGame game)
	{
		super(game);
	}
	
	override
	void Logic(float dt)
	{
		
	}
	
	override
	void Draw(float physics_alpha)
	{
		
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				Game.NextMode = EMode.Exit;
				break;
			}
			default:
			{
				
			}
		}
	}
}
