module game.ITacticalScreen;

import engine.MathTypes;
import game.IGameMode;
import game.Color;

interface ITacticalScreen
{
	IGameMode GameMode();
	SVector2D MainShipPosition();
	SVector2D MainShipVelocity();
	void Damage(SVector2D pos, float damage, SColor color);
	void FireBullet(SVector2D origin, SVector2D target);
}
