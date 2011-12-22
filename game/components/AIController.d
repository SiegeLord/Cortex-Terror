module game.components.AIController;

import game.components.Updatable;
import game.components.Engine;
import game.components.Position;
import game.components.Orientation;
import game.components.PulseCannon;
import game.components.Damageable;
import game.StarSystem;
import game.ITacticalScreen;
import game.IGameMode;
import game.Color;
import game.Bullet;

import engine.IComponentHolder;
import engine.Component;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import allegro5.allegro;

import tango.io.Stdout;
import tango.math.Math;

class CAIController : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		SenseRange = config.Get!(float)("ai_controller", "sense_range", 300);
		MinRange = config.Get!(float)("ai_controller", "min_range", 200);
		MaxRange = config.Get!(float)("ai_controller", "max_range", 300);
		MaxRunAwayTime = config.Get!(float)("ai_controller", "max_run_away_time", 5);
		MaxPatrolRange = config.Get!(float)("ai_controller", "max_patrol_range", 5000);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Engine = GetComponent!(CEngine)(holder, "ai_controller", "engine");
		Position = GetComponent!(CPosition)(holder, "ai_controller", "position");
		Orientation = GetComponent!(COrientation)(holder, "ai_controller", "orientation");
		PulseCannon = GetComponent!(CPulseCannon)(holder, "ai_controller", "pulse_cannon");
		Damageable = cast(CDamageable)holder.GetComponent(CDamageable.classinfo);
	}
	
	override
	void Update(float dt)
	{
		auto home_target = (Planet is null || Planet.Population <= 0)? SVector2D(0, 0) : (Planet.Position * ConversionFactor);
		
		auto to_main = Screen.MainShipPosition - Position.Position;
		auto to_home = home_target - Position.Position;
		
		bool attacking = false;
		if(to_home.LengthSq > MaxPatrolRange * MaxPatrolRange)
		{
			Target = home_target;
		}
		else if(to_main.LengthSq < SenseRange * SenseRange)
		{
			Target = Screen.MainShipPosition;
			attacking = true;
		}
		else
		{
			Target = home_target;
		}
		
		auto dir = Target - Position.Position;
		auto range = dir.Length;
		dir /= range;
		
		Engine.On = true;
		
		if(range < MinRange)
		{
			Chasing = false;
		}
		else if(range > MaxRange || RunAwayTime > MaxRunAwayTime)
		{
			RunAwayTime = 0;
			Chasing = true;
		}
		
		if(!Chasing)
		{
			dir = -dir;
			RunAwayTime += dt;
		}
		
		if(attacking && range < MaxRange)
		{
			PulseCannon.Target = Target;
			PulseCannon.TargetVelocity = Screen.MainShipVelocity;
			PulseCannon.On = true;
		}
		else
			PulseCannon.On = false;
			
		auto face_vec = SVector2D(1, 0);
		face_vec.Rotate(Orientation.Theta);
		auto cross = dir.CrossProduct(face_vec);
		auto dot = dir.DotProduct(face_vec);

		if(cross < -0.01)
		{
			Engine.Left = false;
			Engine.Right = true;
		}
		else if(cross > 0.01)
		{
			Engine.Left = true;
			Engine.Right = false;
		}
		else if(dot < 0)
		{
			Engine.Left = true;
			Engine.Right = false;
		}
		else
		{
			Engine.Left = false;
			Engine.Right = false;
		}
	}
	
	CPlanet Planet(CPlanet planet)
	{
		PlanetVal = planet;
		if(Damageable)
		{
			Damageable.ShieldColor = Planet.ShieldColor;
		}
		return planet;
	}
	
	CPlanet Planet()
	{
		return PlanetVal;
	}
	
	mixin(Prop!("ITacticalScreen", "Screen", "", ""));
protected:
	CPlanet PlanetVal;
	float RunAwayTime = 0;
	float MaxRunAwayTime = 2;
	bool Chasing = true;
	float MinRange;
	float MaxRange;
	float MaxPatrolRange;
	float SenseRange;
	SVector2D Target;
	CPosition Position;
	COrientation Orientation;
	CPulseCannon PulseCannon;
	CDamageable Damageable;
	CEngine Engine;
	ITacticalScreen ScreenVal;
}



