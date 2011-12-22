module game.components.Cannon;

import game.components.Updatable;
import game.components.Position;
import game.components.Orientation;
import game.ITacticalScreen;
import game.IGameMode;
import game.Color;
import game.Bullet;

import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;
import engine.Util;

import tango.math.IEEE;
import tango.math.Math;
import tango.io.Stdout;
import tango.text.convert.Format;

import allegro5.allegro;
import allegro5.allegro_primitives;

struct SCannon
{
	SVector2D Location;
	float Theta;
	float Spread;
	bool On;
	SVector2D Target;
	
	SVector2D GetWorldLocation(SVector2D ship_pos, float ship_theta)
	{
		auto loc = Location;
		loc.Rotate(ship_theta);
		loc += ship_pos;
		return loc;
	}
	
	void CheckArcLead(SVector2D target, SVector2D target_velocity, SVector2D ship_pos, float ship_theta, float max_range)
	{
		auto dir = target - GetWorldLocation(ship_pos, ship_theta);
		
		auto a = BulletSpeed * BulletSpeed;
		auto b = -2.0f * (dir.X * target_velocity.X + dir.Y * target_velocity.Y);
		auto c = -(dir.LengthSq);
		
		auto det = b * b - 4 * a * c;
		if(det > 0)
		{
			auto t1 = (-b + sqrt(det)) / (2 * a);
			auto t2 = (-b - sqrt(det)) / (2 * a);
			
			auto t = max(t2, t1);
			if(t > 0)
			{
				target += target_velocity * t;
			}
		}
		
		CheckArc(target, ship_pos, ship_theta, max_range);
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
		cannon_dir.Rotate(Theta + ship_theta);
		auto dot = dir.DotProduct(cannon_dir);
		auto min_dot = cos(Spread / 2);
		On = dot > min_dot;
		Target = target;
	}
}

const BeamEnergy = 0.1f;

class CCannon : CUpdatable
{
	this(CConfig config)
	{
		super(config);
		size_t n = 0;
		MaxRange = config.Get!(float)(Name, "max_range", 200);
		while(true)
		{
			bool is_def;
			auto str = Format("location{}", n);
			auto location = config.Get!(float[])(Name, str, null, &is_def);
			if(is_def || location.length != 2)
				break;
			
			str = Format("theta{}", n);
			auto theta = config.Get!(float)(Name, str, 0.0f, &is_def);
			if(is_def)
				break;
				
			str = Format("spread{}", n);
			auto spread = config.Get!(float)(Name, str, 0.0f, &is_def);
			if(is_def)
				break;

			Cannons ~= SCannon(SVector2D(location[0], location[1]), theta, spread, false, SVector2D(0, 0));

			n++;
		}
	}
	
	override
	void WireUp(IComponentHolder holder)
	{
		Position = GetComponent!(CPosition)(holder, Name, "position");
		Orientation = GetComponent!(COrientation)(holder, Name, "orientation");
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
	
	abstract
	const(char)[] Name();
	
	SCannon[] Cannons;
	mixin(Prop!("ITacticalScreen", "Screen", "", ""));
	mixin(Prop!("SVector2D", "Target", "", ""));
protected:
	SVector2D TargetVal;
	float MaxRange;
	ITacticalScreen ScreenVal;
	bool OnVal = false;
	
	CPosition Position;
	COrientation Orientation;
}


