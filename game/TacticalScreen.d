module game.TacticalScreen;

import game.Screen;
import game.IGameMode;
import game.GameObject;
import game.components.Star;
import game.components.Sprite;
import game.components.Position;
import game.components.Orientation;
import game.components.Controller;

import engine.MathTypes;

import allegro5.allegro;

class CTacticalScreen : CScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
		auto star_obj = AddObject("star");
		auto star = cast(CStar)star_obj.GetComponent(CStar.classinfo);
		if(star is null)
			throw new Exception("'star.cfg' object needs a 'star' component");
		star.StarSystem = game_mode.CurrentStarSystem;
		
		MainShip = AddObject("main_ship");
		MainShip.Select!(CPosition).Set(500, 300);
		MainShip.Select!(COrientation).Set(0);
		MainShipController = cast(CController)MainShip.GetComponent(CController.classinfo);
	}
	
	CGameObject AddObject(const(char)[] name)
	{
		auto ret = new CGameObject(GameMode, name);
		ret.Select!(CSprite).LoadBitmaps(GameMode);
		Objects ~= ret;
		return ret;
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
		if(MainShip !is null)
		{
			auto pos = cast(CPosition)MainShip.GetComponent(CPosition.classinfo);
			MainShipPosition = pos.Position;
		}
		auto mid = GameMode.Game.Gfx.ScreenSize / 2;
		ALLEGRO_TRANSFORM trans;
		al_identity_transform(&trans);
		al_translate_transform(&trans, mid.X - MainShipPosition.X, mid.Y - MainShipPosition.Y);
		al_use_transform(&trans);
		
		foreach(object; Objects)
			object.Draw(physics_alpha);
		
		GameMode.Game.Gfx.ResetTransform;
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
		
		if(MainShipController !is null)
		{
			MainShipController.Input(event);
		}
	}
	
protected:
	SVector2D MainShipPosition;
	CGameObject[] Objects;
	CGameObject MainShip;
	CController MainShipController;
}
