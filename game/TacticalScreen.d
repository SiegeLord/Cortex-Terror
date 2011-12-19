module game.TacticalScreen;

import game.Screen;
import game.IGameMode;
import game.GameObject;
import game.components.Star;

import allegro5.allegro;

class CTacticalScreen : CScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
		auto star_obj = new CGameObject(GameMode, "star");
		auto star = cast(CStar)star_obj.GetComponent(CStar.classinfo);
		if(star is null)
			throw new Exception("'star.cfg' object needs a 'star' component");
		star.StarSystem = game_mode.CurrentStarSystem;
		Objects ~= star_obj;
		
		
	}
	
	override
	void Update(float dt)
	{
		foreach(object; Objects)
			object.Update(dt);
	}
	
	override
	void Draw(float physics_alpha)
	{
		foreach(object; Objects)
			object.Draw(physics_alpha);
	}
	
	override
	void Dispose()
	{
		super.Dispose();
		foreach(object; Objects)
			object.Dispose;
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		if(event.type == ALLEGRO_EVENT_KEY_DOWN)
		{
			if(event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
			{
				GameMode.PopScreen;
			}
		}
	}
	
protected:
	CGameObject[] Objects;
}
