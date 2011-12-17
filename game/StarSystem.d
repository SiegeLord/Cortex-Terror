module game.StarSystem;

import game.IGameMode;

import engine.Disposable;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.io.Stdout;

class CStarSystem : CDisposable
{
	this(IGameMode game_mode, SVector2D position)
	{
		Position = position;
		GameMode = game_mode;
	}
	
	void DrawGalaxyView(float physics_alpha)
	{
		auto x = (Position.X - GameMode.GalaxyLocation.X) * GameMode.GalaxyZoom + GameMode.Game.Gfx.ScreenWidth / 2;
		auto y = (Position.Y - GameMode.GalaxyLocation.Y) * GameMode.GalaxyZoom + GameMode.Game.Gfx.ScreenHeight / 2;
		al_draw_filled_circle(x, y, 10, al_map_rgb_f(1, 0, 0));
	}

	SVector2D Position;
protected:
	IGameMode GameMode;
}
