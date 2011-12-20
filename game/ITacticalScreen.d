module game.ITacticalScreen;

import engine.MathTypes;
import game.IGameMode;

interface ITacticalScreen
{
	IGameMode GameMode();
	SVector2D MainShipPosition();
	void Damage(SVector2D pos, float damage);
}
