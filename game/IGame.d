module game.IGame;

import engine.Gfx;
import engine.Sfx;

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
	CSfx Sfx();
}
