module game.Main;

import game.Game;

void main()
{
	auto game = new CGame();
	scope(exit) game.Dispose;
	
	game.Run;
}
