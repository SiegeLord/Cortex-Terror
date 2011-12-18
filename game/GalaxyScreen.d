module game.GalaxyScreen;

import game.Screen;
import game.IGameMode;
import game.StarSystem;

import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

const CircleRadius = 13;

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
		
		auto cur_pos = GameMode.ToGalaxyView(GameMode.GalaxyLocation);
		
		if(DestinationSystem !is null)
		{
			auto to = GameMode.ToGalaxyView(DestinationSystem.Position);
			
			al_draw_circle(to.X, to.Y, CircleRadius, al_map_rgb_f(1, 1, 1), 2);
			
			auto dir_vec = (to - cur_pos);
			auto len = dir_vec.Length;
			if(len > CircleRadius * 2)
			{
				dir_vec /= len;
				auto start = dir_vec * CircleRadius + cur_pos;
				auto end = -dir_vec * CircleRadius + to;
				
				al_draw_line(start.X, start.Y, end.X, end.Y, al_map_rgb_f(1, 1, 1), 2);
			}
		}
		
		al_draw_circle(cur_pos.X, cur_pos.Y, CircleRadius, al_map_rgb_f(1, 1, 1), 2);
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
		else if(event.type == ALLEGRO_EVENT_KEY_DOWN)
		{
			if(event.keyboard.keycode == ALLEGRO_KEY_SPACE)
			{
				if(DestinationSystem !is null)
					GameMode.CurrentStarSystem = DestinationSystem;
			}
		}
	}
protected:
	CStarSystem DestinationSystem;
}
