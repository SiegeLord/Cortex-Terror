module game.IGame;

enum EMode
{
	MainMenu,
	Exit
}

interface IGame
{
	void NextMode(EMode mode);
	float Time();
}
