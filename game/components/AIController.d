module game.components.AIController;

import game.components.Updatable;
import game.components.Engine;
import game.components.Position;
import game.components.Orientation;
import game.components.PulseCannon;
import game.ITacticalScreen;
import game.IGameMode;
import game.Color;

import engine.IComponentHolder;
import engine.Component;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import allegro5.allegro;

import tango.io.Stdout;

class CAIController : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		SenseRange = config.Get!(float)("ai_controller", "sense_range", 300);
		MinRange = config.Get!(float)("ai_controller", "min_range", 200);
		MaxRange = config.Get!(float)("ai_controller", "max_range", 300);
		MaxRunAwayTime = config.Get!(float)("ai_controller", "max_run_away_time", 5);
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Engine = GetComponent!(CEngine)(holder, "ai_controller", "engine");
		Position = GetComponent!(CPosition)(holder, "ai_controller", "position");
		Orientation = GetComponent!(COrientation)(holder, "ai_controller", "orientation");
		PulseCannon = GetComponent!(CPulseCannon)(holder, "ai_controller", "pulse_cannon");
	}
	
	override
	void Update(float dt)
	{
		auto to_main = Screen.MainShipPosition - Position.Position;
		bool attacking = false;
		if(to_main.LengthSq < SenseRange * SenseRange)
		{
			Target = Screen.MainShipPosition;
			attacking = true;
		}
		else
		{
			Target = SVector2D(0, 0);
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
	
	mixin(Prop!("ITacticalScreen", "Screen", "", ""));
protected:
	float RunAwayTime = 0;
	float MaxRunAwayTime = 2;
	bool Chasing = true;
	float MinRange;
	float MaxRange;
	float SenseRange;
	SVector2D Target;
	CPosition Position;
	COrientation Orientation;
	CPulseCannon PulseCannon;
	CEngine Engine;
	ITacticalScreen ScreenVal;
}



