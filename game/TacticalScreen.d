module game.TacticalScreen;

import game.Screen;
import game.Bullet;
import game.Color;
import game.IGameMode;
import game.ITacticalScreen;
import game.GameObject;
import ss = game.StarSystem;
import game.components.Star;
import game.components.Sprite;
import game.components.Position;
import game.components.Orientation;
import game.components.AIController;
import game.components.Controller;
import game.components.Planet;
import game.components.BeamCannon;
import game.components.Damageable;
import game.components.Cannon;
import game.components.Ship;

import engine.MathTypes;
import engine.Util;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import tango.stdc.stringz;
import tango.math.random.Random;
import tango.math.Math;
import tango.io.Stdout;
import ar = tango.core.Array;

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
		
		SystemWasAlive = game_mode.CurrentStarSystem.HaveLifeforms;
		
		foreach(planet; game_mode.CurrentStarSystem.Planets)
		{
			auto planet_obj = AddObject("planet");
			auto planet_comp = cast(CPlanet)planet_obj.GetComponent(CPlanet.classinfo);
			if(planet_comp is null)
				throw new Exception("'planet.cfg' object needs a 'planet' component");
			planet_comp.Planet = planet;
			planet_comp.Screen = this;
			
			auto planet_pos = planet.Position;
			
			if(planet.Population > 0)
			{
				int threat = 0;
				if(planet.ShieldColor.Check(EColor.Red))
					threat++;
				if(planet.ShieldColor.Check(EColor.Green))
					threat++;
				if(planet.ShieldColor.Check(EColor.Blue))
					threat++;
				
				void add_ship(const(char)[] type)
				{
					auto ship = AddObject(type);
					auto offset = SVector2D(100, 0);
					offset.Rotate(rand.uniformR(2 * PI));
					ship.Select!(CPosition).Set(planet_pos.X * ss.ConversionFactor + offset.X, planet_pos.Y * ss.ConversionFactor + offset.Y);
					auto controller = cast(CAIController)ship.GetComponent(CAIController.classinfo);
					if(controller is null)
						throw new Exception("'"~ type.idup ~ ".cfg' object needs a 'ai_controller' component");
					
					controller.Screen(this);
					controller.Planet(planet);
						
					auto ship_comp = cast(CShip)ship.GetComponent(CShip.classinfo);
					if(ship_comp !is null)
					{
						ship_comp.Screen = this;
					}
				}
				
				foreach(ii; 0..threat * 2)
				{
					add_ship("small_ship");
				}
				
				foreach(ii; 0..(threat - 1))
				{
					add_ship("medium_ship");
				}
			}
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
		MainShipDamageable = cast(CDamageable)MainShip.GetComponent(CDamageable.classinfo);
	}
	
	CGameObject AddObject(const(char)[] name)
	{
		auto ret = new CGameObject(GameMode, name);
		ret.Select!(CSprite).LoadBitmaps(GameMode);
		ret.Select!(CCannon).Screen(this);
		Objects ~= ret;
		return ret;
	}
	
	override
	void Update(float dt)
	{
		foreach(object; Objects)
			object.Update(dt);
			
		foreach(ref bullet; ActiveBullets)
			bullet.Update(dt);
			
		if(MainShipDamageable !is null)
		{
			foreach(ref bullet; ActiveBullets)
			{
				if(MainShipDamageable.Collide(bullet.Position))
				{
					GameMode.Health = GameMode.Health - 5;
					bullet.Life = -1;
				}
			}
		}
		
		if(GameMode.Health == 0 && MainShip !is null)
		{
			Objects.length = ar.remove(Objects, MainShip);
			MainShip.Dispose;
			MainShip = null;
			MainShipController = null;
			MainShipDamageable = null;
		}
			
		if(MainShip !is null)
		{
			auto pos = cast(CPosition)MainShip.GetComponent(CPosition.classinfo);
			MainShipPosition = pos.Position;
			auto beam = cast(CBeamCannon)MainShip.GetComponent(CBeamCannon.classinfo);
			GameMode.BeamSelection = beam.Selection();
		}
			
		GameMode.Energy = GameMode.Energy + dt * GameMode.CurrentStarSystem.EnergyFlux(MainShipPosition.Length);
		
		auto new_len = ar.removeIf(Objects, 
		(CGameObject obj)
		{
			auto dmg = cast(CDamageable)obj.GetComponent(CDamageable.classinfo);
			if(dmg !is null)
				return dmg.Mortal && dmg.Hitpoints <= 0;
			else
				return false;
		}
		);
		
		if(BossShip !is null)
		{
			auto dmg = cast(CDamageable)BossShip.GetComponent(CDamageable.classinfo);
			if(dmg !is null && dmg.Mortal && dmg.Hitpoints <= 0)
			{
				BossShip = null;
			}
		}
		
		foreach(obj; Objects[new_len..$])
		{
			if(obj == TargetObject)
			{
				TargetObject = null;
				TargetDrawer = null;
			}
			obj.Dispose();
		}
		
		Objects.length = new_len;
		
		new_len = ar.removeIf(ActiveBullets, (SBullet bullet) { return bullet.Life < 0; });
		ActiveBullets = AllBullets[0..new_len];
		
		if(SystemWasAlive && !GameMode.CurrentStarSystem.HaveLifeforms)
		{
			GameMode.RacesLeft = GameMode.RacesLeft - 1;
			Stdout(GameMode.RacesLeft).nl;
			SystemWasAlive = false;
			
			if(GameMode.RacesLeft == 39 && MainShip !is null)
			{
				Stdout("Here").nl;
				
				auto ship = AddObject("large_ship");
				auto offset = SVector2D(100, 0);
				offset.Rotate(rand.uniformR(2 * PI));
				ship.Select!(CPosition).Set(MainShipPosition.X + offset.X, MainShipPosition.Y + offset.Y);
				auto controller = cast(CAIController)ship.GetComponent(CAIController.classinfo);
				if(controller is null)
					throw new Exception("'large_ship.cfg' object needs a 'ai_controller' component");
				controller.Screen(this);
				
				auto ship_comp = cast(CShip)ship.GetComponent(CShip.classinfo);
				if(ship_comp !is null)
				{
					ship_comp.Screen = this;
				}
				
				BossShip = ship;
			}
		}
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
			
		foreach(bullet; ActiveBullets)
			bullet.Draw(physics_alpha);
		
		GameMode.Game.Gfx.ResetTransform;
		
		if(MainShip is null)
		{
			al_draw_text(GameMode.UIFont.Get, al_map_rgb_f(0.5, 1, 0.5), mid.X, mid.Y - GameMode.UIFont.Height / 2, ALLEGRO_ALIGN_CENTRE, "Game Over");
		}
		else
		{
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
						if(MainShip is null || GameMode.Health == GameMode.MaxHealth)
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
					Firing = true;
				}
				else if(event.mouse.button == 2)
				{
					TargetObject = null;
					TargetDrawer = null;
				}
				break;
			}
			case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
			{
				if(event.mouse.button == 1)
				{
					Firing = false;
				}
				break;
			}
			case ALLEGRO_EVENT_MOUSE_AXES:
			{
				if(Firing)
				{
					auto world_pos = SVector2D(event.mouse.x, event.mouse.y) + MainShipPosition - GameMode.Game.Gfx.ScreenSize / 2;
					foreach(object; Objects)
					{
						if(object != MainShip)
						{
							auto damageable = cast(CDamageable)object.GetComponent(CDamageable.classinfo);
							if(damageable !is null && damageable.Collide(world_pos))
							{
								auto planet = cast(CPlanet)object.GetComponent(CPlanet.classinfo);
								if(planet !is null)
								{
									TargetObject = object;
									TargetDrawer = &planet.DrawTarget;
									break;
								}
								
								auto ship = cast(CShip)object.GetComponent(CShip.classinfo);
								if(ship !is null)
								{
									TargetObject = object;
									TargetDrawer = &ship.DrawTarget;
									break;
								}
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
				auto damageable = cast(CDamageable)object.GetComponent(CDamageable.classinfo);
				if(damageable !is null && damageable.Collide(pos))
				{
					damageable.Damage(damage, color);
				}
			}
		}
	}
	
	override
	void FireBullet(SVector2D origin)
	{
		if(ActiveBullets.length == AllBullets.length)
		{
			AllBullets.length = AllBullets.length + 1;
		}
		
		AllBullets[ActiveBullets.length].Launch(origin, (MainShipPosition - origin).Normalize);
		ActiveBullets = AllBullets[0..ActiveBullets.length + 1];
	}
	
	override
	IGameMode GameMode()
	{
		return super.GameMode;
	}
	
	mixin(Prop!("SVector2D", "MainShipPosition", "override", ""));
protected:
	bool Firing = false;
	bool SystemWasAlive = false;
	SBullet[] ActiveBullets;
	SBullet[] AllBullets;
	
	CGameObject TargetObject;
	void delegate(float) TargetDrawer;
	
	bool DrawMap = false;
	SVector2D MainShipPositionVal;
	CGameObject[] Objects;
	
	CGameObject BossShip;
	CGameObject MainShip;
	CController MainShipController;
	CDamageable MainShipDamageable;
}
