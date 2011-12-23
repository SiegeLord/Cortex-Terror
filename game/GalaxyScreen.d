module game.GalaxyScreen;

import game.Screen;
import game.IGameMode;
import game.StarSystem;
import game.StarField;

import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import tango.stdc.stringz;

const CircleRadius = 13;

class CGalaxyScreen : CScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
		StarField = new CStarField(game_mode, GameMode.GalaxyLocation, 0.5, 100);
	}
	
	override
	void Update(float dt)
	{
		CurrentZoom += dt * (TargetZoom - CurrentZoom) / 0.25;
		GameMode.GalaxyZoom = CurrentZoom;
		StarField.Update(GameMode.GalaxyLocation);
		
		if(GameMode.DisplayFinalMessage)
		{
			GameMode.AddMessage("Such insolence! They presumed too much. The galaxy may now be empty of such fools, but the universe still teems with imperfection.", false);
			GameMode.AddMessage("This chapter is now complete... but the story has only just began.");
			GameMode.DisplayFinalMessage = false;
		}
	}
	
	override
	void Draw(float physics_alpha)
	{
		StarField.Draw(GameMode.GalaxyLocation, physics_alpha);
		
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
		al_draw_circle(cur_pos.X, cur_pos.Y, GameMode.Energy * GameMode.GalaxyZoom, al_map_rgb_f(1, 1, 1), 2);
		
		auto screen_size = GameMode.Game.Gfx.ScreenSize;
		
		al_draw_filled_rounded_rectangle(screen_size.X - SideBarWidth, 0, screen_size.X, 650, 15, 15, al_map_rgba_f(0, 0, 0, 0.5));
		
		auto sys = GameMode.CurrentStarSystem;
		if(DestinationSystem !is null)
			sys = DestinationSystem;

		sys.DrawPreview(physics_alpha);
		
		GameMode.DrawLeftSideBar(physics_alpha);
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_MOUSE_AXES:
			{
				if(event.mouse.dz < 0)
					TargetZoom *= 0.9;
				else if(event.mouse.dz > 0)
					TargetZoom *= 1.1;
					
				if(TargetZoom < 0.25)
					TargetZoom = 0.25;
				break;
			}
			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
			{
				if(event.mouse.button == 1)
				{
					auto m_pos = SVector2D(event.mouse.x, event.mouse.y);
					if(m_pos.X > SideBarWidth && m_pos.X < GameMode.Game.Gfx.ScreenWidth - SideBarWidth)
					{
						auto pos = GameMode.FromGalaxyView(m_pos);
						DestinationSystem = GameMode.Galaxy.GetStarSystemAt(pos, 
						   (CStarSystem sys) { return (sys.Position - GameMode.GalaxyLocation).LengthSq < GameMode.Energy * GameMode.Energy; });
						DestinationSystem.Scanned = true;
					}
				}
				else
				{
					DestinationSystem = null;
				}
				break;
			}
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				if(event.keyboard.keycode == ALLEGRO_KEY_SPACE)
				{
					if(DestinationSystem !is null)
						GameMode.CurrentStarSystem = DestinationSystem;
				}
				else if(event.keyboard.keycode == ALLEGRO_KEY_ENTER)
				{
					if(GameMode.Arrived)
						GameMode.PushScreen(EScreen.Tactical);
				}
				else if(event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
				{
					GameMode.PopScreen;
				}
				break;
			}
			default:
			{
			}
		}
	}
protected:
	CStarField StarField;
	float CurrentZoom = 1.5;
	float TargetZoom = 2;
	CStarSystem DestinationSystem;
}
