module game.MainMenuMode;

import engine.Config;
import engine.ConfigManager;

import game.Mode;
import game.IGame;
import game.GameObject;
import game.components.Position;
import game.components.Physics;
import game.components.Rectangle;

import allegro5.allegro;

import tango.io.Stdout;

class CMainMenuMode : CMode
{
	this(IGame game)
	{
		super(game);
		ConfigManager = new typeof(ConfigManager);
		
		TestObject = new typeof(TestObject)(ConfigManager.Load("data/objects/test.cfg"));
		auto physics = cast(CPhysics)TestObject.GetComponent(CPhysics.classinfo);
		assert(physics);
		physics.Vx = 10;
		physics.Vy = 10;
	}
	
	override
	void Logic(float dt)
	{
		TestObject.Update(dt);
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		TestObject.Draw(physics_alpha);
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				Game.NextMode = EMode.Exit;
				break;
			}
			default:
			{
				
			}
		}
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		TestObject.Dispose;
		ConfigManager.Dispose;
	}
protected:
	CConfigManager ConfigManager;
	CGameObject TestObject;
}
