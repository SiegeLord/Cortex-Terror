module game.TacticalScreen;

import game.Screen;
import game.Color;
import game.IGameMode;
import game.ITacticalScreen;
import game.GameObject;
import ss = game.StarSystem;
import game.components.Star;
import game.components.Sprite;
import game.components.Position;
import game.components.Orientation;
import game.components.Controller;
import game.components.Planet;
import game.components.BeamCannon;
import game.components.Damageable;

import engine.MathTypes;
import engine.Util;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import tango.stdc.stringz;
import tango.math.random.Random;
import tango.math.Math;
import tango.io.Stdout;

class CTacticalScreen : CScreen, ITacticalScreen
{
	this(IGameMode game_mode)
	{
		super(game_mode);
		
		auto star_obj = AddObject("star");
		auto star = cast(CStar)star_obj.GetComponent(CStar.classinfo);
		if(star is null)
			throw new Exception("'star.cfg' object needs a 'star' component");
		star.StarSystem = game_mode.CurrentStarSystem;
		star.Screen = this;
		
		foreach(planet; game_mode.CurrentStarSystem.Planets)
		{
			auto planet_obj = AddObject("planet");
			auto planet_comp = cast(CPlanet)planet_obj.GetComponent(CPlanet.classinfo);
			if(planet_comp is null)
				throw new Exception("'planet.cfg' object needs a 'planet' component");
			planet_comp.Planet = planet;
			planet_comp.Screen = this;
		}
		
		SVector2D start_pos;
		if(game_mode.CurrentStarSystem.HaveLifeforms)
			start_pos = SVector2D(ss.MaxRadius * 1.1 * ss.ConversionFactor, 0);
		else
			start_pos = SVector2D(ss.MaxRadius * 0.1 * ss.ConversionFactor, 0);
		auto theta = rand.uniformR(2 * PI);
		start_pos.Rotate(theta + PI);
		
		MainShip = AddObject("main_ship");
		MainShip.Select!(CPosition).Set(start_pos.X, start_pos.Y);
		MainShip.Select!(COrientation).Set(theta);
		MainShip.Select!(CBeamCannon).Selection(GameMode.BeamSelection);
		MainShipController = cast(CController)MainShip.GetComponent(CController.classinfo);
		MainShipController.Screen(this);
	}
	
	CGameObject AddObject(const(char)[] name)
	{
		auto ret = new CGameObject(GameMode, name);
		ret.Select!(CSprite).LoadBitmaps(GameMode);
		ret.Select!(CBeamCannon).Screen(this);
		Objects ~= ret;
		return ret;
	}
	
	override
	void Update(float dt)
	{
		foreach(object; Objects)
			object.Update(dt);
			
		if(MainShip !is null)
		{
			auto pos = cast(CPosition)MainShip.GetComponent(CPosition.classinfo);
			MainShipPosition = pos.Position;
			auto beam = cast(CBeamCannon)MainShip.GetComponent(CBeamCannon.classinfo);
			GameMode.BeamSelection = beam.Selection();
		}
			
		GameMode.Energy = GameMode.Energy + dt * GameMode.CurrentStarSystem.EnergyFlux(MainShipPosition.Length);
	}
	
	override
	void Draw(float physics_alpha)
	{
		auto mid = GameMode.Game.Gfx.ScreenSize / 2;
		ALLEGRO_TRANSFORM trans;
		al_identity_transform(&trans);
		al_translate_transform(&trans, mid.X - MainShipPosition.X, mid.Y - MainShipPosition.Y);
		al_use_transform(&trans);
		
		foreach(object; Objects)
			object.Draw(physics_alpha);
		
		GameMode.Game.Gfx.ResetTransform;
		
		if(DrawMap)
		{
			auto cur_sys = GameMode.CurrentStarSystem;
			
			al_identity_transform(&trans);
			al_translate_transform(&trans, mid.X - MainShipPosition.X / ss.ConversionFactor, mid.Y - MainShipPosition.Y / ss.ConversionFactor);
			al_use_transform(&trans);
			
			cur_sys.DrawSystemView(physics_alpha);
			
			GameMode.Game.Gfx.ResetTransform;
			
			al_draw_text(GameMode.UIFont.Get, al_map_rgb_f(0.5, 1, 0.5), mid.X, 2 * mid.Y - GameMode.UIFont.Height - 10, ALLEGRO_ALIGN_CENTRE, toStringz(cur_sys.Name));
		}
		GameMode.DrawLeftSideBar(physics_alpha);
		if(TargetDrawer !is null)
			TargetDrawer(physics_alpha);
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
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_TAB:
						DrawMap = !DrawMap;
						break;
					case ALLEGRO_KEY_ESCAPE:
						GameMode.PopScreen;
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
			{
				if(event.mouse.button == 1)
				{
					auto world_pos = SVector2D(event.mouse.x, event.mouse.y) + MainShipPosition - GameMode.Game.Gfx.ScreenSize / 2;
					foreach(object; Objects)
					{
						if(object != MainShip)
						{
							auto planet = cast(CPlanet)object.GetComponent(CPlanet.classinfo);
							if(planet !is null && planet.Collide(world_pos))
							{
								TargetDrawer = &planet.DrawTarget;
								break;
							}
							
							auto star = cast(CStar)object.GetComponent(CStar.classinfo);
							if(star !is null && star.Collide(world_pos))
							{
								TargetDrawer = &star.DrawTarget;
								break;
							}
						}
					}
				}
				else if(event.mouse.button == 2)
				{
					TargetDrawer = null;
				}
			}
			default:
		}
		
		if(MainShipController !is null)
		{
			MainShipController.Input(event);
		}
	}
	
	override
	void Damage(SVector2D pos, float damage, SColor color)
	{
		foreach(object; Objects)
		{
			if(object != MainShip)
			{
				auto planet = cast(CPlanet)object.GetComponent(CPlanet.classinfo);
				if(planet !is null && planet.Collide(pos))
				{
					object.Select!(CDamageable).Damage(damage, color);
					break;
				}
			}
		}
	}
	
	override
	IGameMode GameMode()
	{
		return super.GameMode;
	}
	
	mixin(Prop!("SVector2D", "MainShipPosition", "override", ""));
protected:
	void delegate(float) TargetDrawer;
	bool DrawMap = false;
	SVector2D MainShipPositionVal;
	CGameObject[] Objects;
	CGameObject MainShip;
	CController MainShipController;
}
