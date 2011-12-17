module game.IGameMode;

import game.IGame;

import engine.MathTypes;

interface IGameMode
{
	SVector2D GalaxyLocation();
	float GalaxyZoom();
	IGame Game();
}
