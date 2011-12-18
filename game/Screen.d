module game.Screen;

import engine.Disposable;

import game.IGameMode;

import allegro5.allegro;

class CScreen : CDisposable
{
	this(IGameMode game_mode)
	{
		GameMode = game_mode;
	}
	
	void Update(float dt) {};
	void Draw(float physics_alpha) {};
	void Input(ALLEGRO_EVENT* event) {};
protected:
	IGameMode GameMode;
}
