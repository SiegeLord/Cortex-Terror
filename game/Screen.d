module game.Screen;

import engine.Disposable;
import engine.Util;

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
	mixin(Prop!("IGameMode", "GameMode", "", "protected"));
protected:
	IGameMode GameModeVal;
}
