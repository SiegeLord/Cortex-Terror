module game.IGameMode;

import game.IGame;
import game.Galaxy;
import game.StarSystem;

import engine.Font;
import engine.MathTypes;
import engine.BitmapManager;
import engine.ConfigManager;

enum EScreen
{
	Galaxy,
	System,
	Tactical
}

interface IGameMode
{
	SVector2D GalaxyLocation();
	SVector2D ToGalaxyView(SVector2D galaxy_pos);
	SVector2D FromGalaxyView(SVector2D galaxy_view);
	float GalaxyZoom();
	float GalaxyZoom(float new_zoom);
	float WarpRange(float new_range);
	float WarpRange();
	float WarpSpeed(float new_speed);
	float WarpSpeed();
	bool Arrived();
	IGame Game();
	CGalaxy Galaxy();
	void PushScreen(EScreen screen);
	void PopScreen();
	CStarSystem CurrentStarSystem();
	CStarSystem CurrentStarSystem(CStarSystem new_star_system);
	CFont UIFont();
	CBitmapManager BitmapManager();
	CConfigManager ConfigManager();
}
