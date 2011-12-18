module game.GameMode;

import engine.Config;
import engine.ConfigManager;
import engine.MathTypes;
import engine.Util;

import game.Mode;
import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.Galaxy;
import game.GalaxyScreen;
import game.StarSystem;
import game.Screen;

import allegro5.allegro;

import tango.io.Stdout;

class CGameMode : CMode, IGameMode
{
	this(IGame game)
	{
		super(game);
		ConfigManager = new CConfigManager;
		Galaxy = new CGalaxy(this, 2);
		CurrentStarSystem = Galaxy.GetStarSystemAt(GalaxyLocation);
		GalaxyLocation = CurrentStarSystem.Position;
		Screen = new CGalaxyScreen(this);
	}
	
	override
	void Logic(float dt)
	{
		if(WantScreenSwitch)
		{
			WantScreenSwitch = false;
		}
		
		Screen.Draw(dt);
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		Screen.Draw(physics_alpha);
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		Screen.Input(event);
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
	
	override
	void Dispose()
	{
		super.Dispose;
		Galaxy.Dispose;
		ConfigManager.Dispose;
	}
	
	override
	IGame Game()
	{
		return CMode.Game;
	}
	
	override
	float GalaxyZoom()
	{
		return GalaxyZoomVal;
	}
	
	override
	float GalaxyZoom(float new_zoom)
	{
		if(new_zoom < 0.25)
			new_zoom = 0.25;
		
		return GalaxyZoomVal = new_zoom;
	}
	
	mixin(Prop!("CGalaxy", "Galaxy", "override", "protected"));
	mixin(Prop!("SVector2D", "GalaxyLocation", "override", "protected"));
	mixin(Prop!("EScreen", "NextScreen", "", "override"));
protected:
	SVector2D GalaxyLocationVal;
	CConfigManager ConfigManager;
	CGalaxy GalaxyVal;
	CScreen Screen;
	bool WantScreenSwitch = false;
	EScreen NextScreenVal;
	CStarSystem CurrentStarSystem;
	float GalaxyZoomVal = 1;
}
