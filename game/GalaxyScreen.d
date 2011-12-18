module game.GalaxyScreen;

import game.Screen;
import game.IGameMode;
import game.StarSystem;

import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

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
		if(DestinationSystem !is null)
		{
			auto from = GameMode.ToGalaxyView(GameMode.CurrentStarSystem.Position);
			auto to = GameMode.ToGalaxyView(DestinationSystem.Position);
			al_draw_line(from.X, from.Y, to.X, to.Y, al_map_rgb_f(1, 1, 1), 2);
		}
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
		else if(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN)
		{
			if(event.mouse.button == 1)
			{
				auto pos = GameMode.FromGalaxyView(SVector2D(event.mouse.x, event.mouse.y));
				DestinationSystem = GameMode.Galaxy.GetStarSystemAt(pos);
			}
			else
			{
				DestinationSystem = null;
			}
		}
	}
protected:
	CStarSystem DestinationSystem;
}
