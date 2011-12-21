module game.components.AIController;

import game.components.Updatable;
import game.components.Engine;
import game.components.Position;
import game.components.Orientation;
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
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Engine = GetComponent!(CEngine)(holder, "ai_controller", "engine");
		Position = GetComponent!(CPosition)(holder, "ai_controller", "position");
		Orientation = GetComponent!(COrientation)(holder, "ai_controller", "orientation");
	}
	
	override
	void Update(float dt)
	{
		auto to_main = Screen.MainShipPosition - Position.Position;
		if(to_main.LengthSq < SenseRange * SenseRange)
		{
			Target = Screen.MainShipPosition;
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
			dir = -dir;
		
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
	float MinRange;
	float MaxRange;
	float SenseRange;
	SVector2D Target;
	CPosition Position;
	COrientation Orientation;
	CEngine Engine;
	ITacticalScreen ScreenVal;
}



