module game.IGameMode;

import game.IGame;
import game.Galaxy;
import game.StarSystem;

import engine.MathTypes;

enum EScreen
{
	Galaxy
}

interface IGameMode
{
	SVector2D GalaxyLocation();
	SVector2D ToGalaxyView(SVector2D galaxy_pos);
	SVector2D FromGalaxyView(SVector2D galaxy_view);
	float GalaxyZoom();
	float GalaxyZoom(float new_zoom);
	IGame Game();
	CGalaxy Galaxy();
	EScreen NextScreen(EScreen screen);
	CStarSystem CurrentStarSystem();
	CStarSystem CurrentStarSystem(CStarSystem new_star_system);
}
