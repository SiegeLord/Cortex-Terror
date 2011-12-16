module game.MainMenuMode;

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
		
		TestObject = new typeof(TestObject);
		with(TestObject)
		{
			AddComponent(new CPosition);
			AddComponent(new CPhysics);
			AddComponent(new CRectangle);
		}
		auto physics = cast(CPhysics)TestObject.GetComponent(CPhysics.classinfo);
		assert(physics);
		physics.Vx = 10;
		physics.Vy = 10;
		TestObject.WireUp;
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
protected:
	CGameObject TestObject;
}
