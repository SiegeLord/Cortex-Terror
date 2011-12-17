module game.Mode;

import engine.Disposable;
import engine.Util;

import game.IGame;

import allegro5.allegro;

class CMode : CDisposable
{
	this(IGame game)
	{
		Game = game;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
	}
	
	abstract void Logic(float dt);
	abstract void Draw(float physics_alpha);
	abstract void Input(ALLEGRO_EVENT* event);
	mixin(Prop!("IGame", "Game", "", "protected"));
protected:
	IGame GameVal;
}
