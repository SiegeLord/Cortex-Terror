module game.Main;

import game.Game;
import tango.io.Stdout;

void main()
{
	CGame game;
	try
	{
		game = new CGame();
		game.Run;
	}
	catch(Exception e)
	{
		Stdout("Exception!").nl.nl;
		Stdout(e.msg).nl.nl;
		Stdout.formatln("{}:{}", e.file, e.line);
	}
	finally
	{
		game.Dispose;
	}
}
