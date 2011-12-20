module game.components.BeamCannon;

import game.components.Updatable;
import game.components.Position;
import game.components.Orientation;
import game.ITacticalScreen;
import game.IGameMode;
import game.Color;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import tango.math.IEEE;
import tango.math.Math;
import tango.io.Stdout;
import tango.text.convert.Format;

import allegro5.allegro;

struct SCannon
{
	SVector2D Location;
	float Theta;
	float Spread;
	bool On;
	
	SVector2D GetWorldLocation(SVector2D ship_pos, float ship_theta)
	{
		auto loc = Location;
		loc.Rotate(ship_theta);
		loc += ship_pos;
		return loc;
	}
	
	void CheckArc(SVector2D target, SVector2D ship_pos, float ship_theta, float max_range)
	{
		auto dir = target - GetWorldLocation(ship_pos, ship_theta);
		auto dir_len = dir.Length;
		if(dir_len > max_range)
		{
			On = false;
			return;
		}
		dir /= dir_len;
		auto cannon_dir = SVector2D(1, 0);
		cannon_dir.Rotate(Theta);
		cannon_dir.Rotate(ship_theta);
		auto dot = dir.DotProduct(cannon_dir);
		auto min_dot = cos(Spread / 2);
		On = dot > min_dot;
	}
}

const BeamEnergy = 0.1f;

class CBeamCannon : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		size_t n = 0;
		MaxRange = config.Get!(float)("beam_cannon", "max_range", 200);
		while(true)
		{
			bool is_def;
			auto str = Format("location{}", n);
			auto location = config.Get!(float[])("beam_cannon", str, null, &is_def);
			if(is_def || location.length != 2)
				break;
			
			str = Format("theta{}", n);
			auto theta = config.Get!(float)("beam_cannon", str, 0.0f, &is_def);
			if(is_def)
				break;
				
			str = Format("spread{}", n);
			auto spread = config.Get!(float)("beam_cannon", str, 0.0f, &is_def);
			if(is_def)
				break;

			Cannons ~= SCannon(SVector2D(location[0], location[1]), theta, spread, false);

			n++;
		}
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, "beam_cannon", "position");
		Orientation = GetComponent!(COrientation)(holder, "beam_cannon", "orientation");
	}
	
	override
	void Update(float dt)
	{
		Target = ScreenTarget + Position.Position - Screen.GameMode.Game.Gfx.ScreenSize / 2;
		Target += Position.Position;
		
		if(On)
		{
			size_t n;
			foreach(ref cannon; Cannons)
			{
				cannon.CheckArc(Target, Position.Position, Orientation.Theta, MaxRange);
				if(cannon.On)
					n++;
			}
			
			if(n > 0)
			{
				Screen.Damage(Target, n);
			}
			
			auto energy_usage = dt * n * BeamEnergy;
			
			if(Screen.GameMode.Energy < energy_usage)
			{
				foreach(ref cannon; Cannons)
				{
					cannon.On = false;
				}
			}
			else
			{
				Screen.GameMode.Energy = Screen.GameMode.Energy - energy_usage;
			}
		}
	}
	
	SVector2D ScreenTarget(SVector2D target)
	{
		ScreenTargetVal = target;
		
		return ScreenTargetVal;
	}
	
	SVector2D ScreenTarget()
	{
		return ScreenTargetVal;
	}
	
	bool On(bool val)
	{
		OnVal = val;
		if(!On)
		{
			foreach(ref cannon; Cannons)
			{
				cannon.On = false;
			}
		}
		return On;
	}
	
	bool On()
	{
		return OnVal;
	}
	
	bool Color(EColor color)
	{
		return ColorVal.Check(color);
	}
	
	bool ToggleColor(EColor color)
	{		
		return ColorVal.Toggle(color);
	}
	
	ALLEGRO_COLOR ToColor()
	{
		return ColorVal.ToColor;
	}
	
	
	SCannon[] Cannons;
	mixin(Prop!("ITacticalScreen", "Screen", "", ""));
	mixin(Prop!("SVector2D", "Target", "", "protected"));
protected:
	SColor ColorVal;
	
	SVector2D ScreenTargetVal;
	SVector2D TargetVal;
	float MaxRange;
	ITacticalScreen ScreenVal;
	bool OnVal = false;
	
	CPosition Position;
	COrientation Orientation;
}


