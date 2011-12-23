module game.TacticalScreen;

import game.Screen;
import game.Bullet;
import game.Color;
import game.IGameMode;
import game.ITacticalScreen;
import game.GameObject;
import game.StarField;
import ss = game.StarSystem;
import game.components.Star;
import game.components.Sprite;
import game.components.Position;
import game.components.Orientation;
import game.components.AIController;
import game.components.PulseCannon;
import game.components.Controller;
import game.components.Planet;
import game.components.BeamCannon;
import game.components.Damageable;
import game.components.Cannon;
import game.components.Ship;
import game.components.Physics;

import engine.MathTypes;
import engine.Util;
import engine.Sound;

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
		
		HitSound = GameMode.SoundManager.Load("data/sounds/hit.ogg");
		
		auto star_obj = AddObject("star");
		auto star = cast(CStar)star_obj.GetComponent(CStar.classinfo);
		if(star is null)
			throw new Exception("'star.cfg' object needs a 'star' component");
		star.StarSystem = game_mode.CurrentStarSystem;
		star.Screen = this;
		star.LoadBitmaps(GameMode);
		
		SystemWasAlive = game_mode.CurrentStarSystem.HaveLifeforms;
		
		if(SystemWasAlive)
		{
			switch(rand.uniformR(4))
			{
				case 0:
					GameMode.AddMessage("Time to assimilate these insects.", true, 10);
					break;
				case 1:
					GameMode.AddMessage("Prepare to be a part of something greater than yourself.", true, 10);
					break;
				case 2:
					GameMode.AddMessage("More poor creatures, all yearning to be a part of me.", true, 10);
					break;
				default:
					GameMode.AddMessage("Resistance is fewtile.", true, 10);
			}
		}
		
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
		MainShipPosition = start_pos;
		
		StarFields[0] = new CStarField(GameMode, MainShipPosition, 1, 50);
		StarFields[1] = new CStarField(GameMode, MainShipPosition, 0.5, 100);
	}
	
	CGameObject AddObject(const(char)[] name)
	{
		auto ret = new CGameObject(GameMode, name);
		ret.Select!(CSprite).LoadBitmaps(GameMode);
		ret.Select!(CPulseCannon).LoadSounds(GameMode);
		ret.Select!(CCannon).Screen(this);
		Objects ~= ret;
		return ret;
	}
	
	override
	void Update(float dt)
	{
		GameMode.SoundManager.Update(dt, MainShipPosition);
		
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
					HitSound.Play(MainShipPosition);
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
			assert(pos);
			MainShipPosition = pos.Position;
			auto phys = cast(CPhysics)MainShip.GetComponent(CPhysics.classinfo);
			assert(phys);
			MainShipVelocity = phys.Velocity;
			auto beam = cast(CBeamCannon)MainShip.GetComponent(CBeamCannon.classinfo);
			GameMode.BeamSelection = beam.Selection();
		}
		
		foreach(field; StarFields)
			field.Update(MainShipPosition);
			
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
				GameMode.DisplayFinalMessage = true;
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
			SystemWasAlive = false;
			
			if(GameMode.RacesLeft == 39 && MainShip !is null)
			{
				GameMode.ClearMessages();
				GameMode.AddMessage("My sensory readings indicate that there is no life left in this galaxy. My glorious magnificence will... What is this sensory reading?", false);
				GameMode.AddMessage("Not so fast, demon! Now you will pay for your unspeakable crimes! Behold the vengeful scream of a trillion voices!", true, 10, false);
				
				CGameObject add_ship(const(char)[] type, float theta)
				{
					auto ship = AddObject(type);
					auto offset = SVector2D(1500, 0);
					offset.Rotate(theta);
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
					
					auto damageable_comp = cast(CDamageable)ship.GetComponent(CDamageable.classinfo);
					if(damageable_comp !is null)
					{
						damageable_comp.ShieldColor.ColorFlag = rand.uniformR2(1, 8);
					}
					
					return ship;
				}
				
				foreach(ii; 0..10)
				{
					const(char)[] ship_type = ii == 0 ? "large_ship" : "medium_ship2";
					auto ship = add_ship(ship_type, cast(float)ii * 2 * PI / 10.0f);
					
					if(ii == 0)
						BossShip = ship;
				}
			}
			else
			{
				switch(rand.uniformR(4))
				{
					case 0:
						GameMode.AddMessage("This race is now a part of me.", true, 10);
						break;
					case 1:
						GameMode.AddMessage("The cacophony of individuality is replaced by the symphony of my mind.", true, 10);
						break;
					case 2:
						GameMode.AddMessage("Perfect victory.", true, 10);
						break;
					default:
						GameMode.AddMessage("So many grateful voices inside my consciousness... it is glorious!", true, 10);
				}
			}
		}
	}
	
	override
	void Draw(float physics_alpha)
	{
		foreach(field; StarFields)
			field.Draw(MainShipPosition, physics_alpha);
		
		auto mid = GameMode.Game.Gfx.ScreenSize / 2;
		ALLEGRO_TRANSFORM trans;
		
		void set_camera()
		{
			al_identity_transform(&trans);
			al_translate_transform(&trans, mid.X - MainShipPosition.X, mid.Y - MainShipPosition.Y);
			al_use_transform(&trans);
		}		
		
		set_camera;
		
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
			else if(TargetObject !is null)
			{
				auto pos = cast(CPosition)TargetObject.GetComponent(CPosition.classinfo);
				assert(pos);
				auto dir = pos.Position - MainShipPosition;
				auto theta = atan2(dir.Y, dir.X);
				
				if(dir.LengthSq < 400 * 400)
				{
					/*auto tri_rad = 50;
					auto vtx = SVector2D(tri_rad, 0);
					vtx.Rotate(PI / 6);
					
					set_camera;
					
					al_draw_triangle(pos.X, pos.Y - tri_rad, pos.X - vtx.X, pos.Y + vtx.Y, pos.X + vtx.X, pos.Y + vtx.Y, al_map_rgb_f(0.5, 1, 0.5), 2);
					
					GameMode.Game.Gfx.ResetTransform;*/
				}
				else
				{
					al_identity_transform(&trans);
					al_translate_transform(&trans, 0, -200);
					al_rotate_transform(&trans, theta + PI / 2);
					al_translate_transform(&trans, GameMode.Game.Gfx.ScreenWidth / 2, GameMode.Game.Gfx.ScreenHeight / 2);
					al_use_transform(&trans);

					auto tri_rad = 20;
					auto vtx = SVector2D(tri_rad, 0);
					vtx.Rotate(PI / 6);
					al_draw_triangle(0, -tri_rad, -vtx.X, vtx.Y, vtx.X, vtx.Y, al_map_rgb_f(0.5, 1, 0.5), 2);
					
					GameMode.Game.Gfx.ResetTransform;
				}
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
		void check_target(int mx, int my)
		{
			auto world_pos = SVector2D(mx, my) + MainShipPosition - GameMode.Game.Gfx.ScreenSize / 2;
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
						TargetObject = object;
						TargetDrawer = &star.DrawTarget;
						break;
					}
				}
			}
		}
		
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_TAB:
						DrawMap = !DrawMap;
						GameMode.UISound.Play(MainShipPosition);
						break;
					case ALLEGRO_KEY_ESCAPE:
						if(MainShip is null || (GameMode.Health == GameMode.MaxHealth && BossShip is null))
						{
							GameMode.PopScreen;
						}
						else if(GameMode.Health != GameMode.MaxHealth)
						{
							GameMode.AddMessage("Cannot enter hyperspace while I am damaged.");
						}
						else if(BossShip !is null)
						{
							GameMode.AddMessage("That large ship is causing interference with my hyperspace drive.");
						}
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
			{
				if(event.mouse.button == 1)
				{
					check_target(event.mouse.x, event.mouse.y);
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
					check_target(event.mouse.x, event.mouse.y);
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
					break;
				}
			}
		}
	}
	
	override
	void FireBullet(SVector2D origin, SVector2D target)
	{
		if(ActiveBullets.length == AllBullets.length)
		{
			AllBullets.length = AllBullets.length + 1;
		}
		
		AllBullets[ActiveBullets.length].Launch(origin, (target - origin).Normalize);
		ActiveBullets = AllBullets[0..ActiveBullets.length + 1];
	}
	
	override
	IGameMode GameMode()
	{
		return super.GameMode;
	}
	
	mixin(Prop!("SVector2D", "MainShipPosition", "override", ""));
	mixin(Prop!("SVector2D", "MainShipVelocity", "override", ""));
protected:
	CSound HitSound;

	bool Firing = false;
	bool SystemWasAlive = false;
	SBullet[] ActiveBullets;
	SBullet[] AllBullets;
	
	CGameObject TargetObject;
	void delegate(float) TargetDrawer;
	
	bool DrawMap = false;
	SVector2D MainShipPositionVal;
	SVector2D MainShipVelocityVal;
	CGameObject[] Objects;
	
	CGameObject BossShip;
	CGameObject MainShip;
	CController MainShipController;
	CDamageable MainShipDamageable;
	
	CStarField[2] StarFields;
}
