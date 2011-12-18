module game.IGameMode;

import game.IGame;
import game.Galaxy;

import engine.MathTypes;

enum EScreen
{
	Galaxy
}

interface IGameMode
{
	SVector2D GalaxyLocation();
	float GalaxyZoom();
	float GalaxyZoom(float new_zoom);
	IGame Game();
	CGalaxy Galaxy();
	EScreen NextScreen(EScreen screen);
}
