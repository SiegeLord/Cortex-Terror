module game.SystemScreen;

import game.Screen;
import game.IGameMode;
import game.StarSystem;

import allegro5.allegro;
import allegro5.allegro_font;

import tango.stdc.stringz;

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
		auto cur_sys = GameMode.CurrentStarSystem;
		
		ALLEGRO_TRANSFORM trans;
		al_identity_transform(&trans);
		al_translate_transform(&trans, mid.X, mid.Y);
		al_use_transform(&trans);
		
		cur_sys.DrawSystemView(physics_alpha);
		
		GameMode.Game.Gfx.ResetTransform;
		
		al_draw_text(GameMode.UIFont.Get, al_map_rgb_f(0.5, 1, 0.5), mid.X, 2 * mid.Y - GameMode.UIFont.Height - 10, ALLEGRO_ALIGN_CENTRE, toStringz(cur_sys.Name));
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
