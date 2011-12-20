module game.ITacticalScreen;

import engine.MathTypes;
import game.IGameMode;
import game.Color;

interface ITacticalScreen
{
	IGameMode GameMode();
	SVector2D MainShipPosition();
	void Damage(SVector2D pos, float damage, SColor color);
}
