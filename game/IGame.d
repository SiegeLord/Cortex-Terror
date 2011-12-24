module game.IGame;

import engine.Gfx;
import engine.Sfx;
import engine.Config;

enum EMode
{
	MainMenu,
	Game,
	Exit
}

enum FixedDt = 1.0f/60.0f;

interface IGame
{
	void NextMode(EMode mode);
	float Time();
	CGfx Gfx();
	CSfx Sfx();
	CConfig Options();
}
