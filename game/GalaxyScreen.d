module game.GalaxyScreen;

import game.Screen;
import game.IGameMode;
import allegro5.allegro;

class CGalaxyScreen : CScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
	}
	
	override
	void Update(float dt)
	{
		
	}
	
	override
	void Draw(float physics_alpha)
	{
		GameMode.Galaxy.Draw(physics_alpha);
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		if(event.type == ALLEGRO_EVENT_MOUSE_AXES)
		{
			if(event.mouse.dz < 0)
				GameMode.GalaxyZoom = GameMode.GalaxyZoom * 0.9;
			else if(event.mouse.dz > 0)
				GameMode.GalaxyZoom = GameMode.GalaxyZoom * 1.1;
		}
	}
}
