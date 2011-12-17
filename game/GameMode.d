module game.GameMode;

import engine.Config;
import engine.ConfigManager;
import engine.MathTypes;

import game.Mode;
import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.components.Position;
import game.components.Physics;
import game.components.Rectangle;
import game.Galaxy;

import allegro5.allegro;

import tango.io.Stdout;

class CGameMode : CMode, IGameMode
{
	this(IGame game)
	{
		super(game);
		ConfigManager = new CConfigManager;
		Galaxy = new CGalaxy(this, 2);
	}
	
	override
	void Logic(float dt)
	{
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		Galaxy.Draw(physics_alpha);
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
	
	override
	void Dispose()
	{
		super.Dispose;
		Galaxy.Dispose;
		ConfigManager.Dispose;
	}
	
	override
	SVector2D GalaxyLocation()
	{
		return SVector2D(0, 0);
	}
	
	override
	float GalaxyZoom()
	{
		return 1;
	}
	
	override
	IGame Game()
	{
		return CMode.Game;
	}
protected:
	CConfigManager ConfigManager;
	CGalaxy Galaxy;
}
