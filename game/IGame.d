module game.IGame;

import engine.Gfx;

enum EMode
{
	MainMenu,
	Game,
	Exit
}

interface IGame
{
	void NextMode(EMode mode);
	float Time();
	CGfx Gfx();
}
