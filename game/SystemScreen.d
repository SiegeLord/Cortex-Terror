module game.SystemScreen;

import game.Screen;
import game.IGameMode;
import game.StarSystem;

import allegro5.allegro;

class CSystemScreen : CScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto mid = GameMode.Game.Gfx.ScreenSize / 2;
		
		ALLEGRO_TRANSFORM trans;
		al_identity_transform(&trans);
		al_translate_transform(&trans, mid.X, mid.Y);
		
		GameMode.CurrentStarSystem.DrawSystemView(physics_alpha);
		
		GameMode.Game.Gfx.ResetTransform;
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		if(event.type == ALLEGRO_EVENT_KEY_DOWN)
		{
			if(event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
			{
				GameMode.PopScreen;
			}
		}
	}
}
