module game.components.BeamCannon;

import game.components.Cannon;
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

const BeamEnergy = 0.1f;

class CBeamCannon : CCannon
{
	this(CConfig config)
	{
		super(config);
	}
	
	override
	void Update(float dt)
	{
		Target = ScreenTarget + Position.Position - Screen.GameMode.Game.Gfx.ScreenSize / 2;
		Target += Position.Position;
		
		if(On)
		{
			auto energy_usage = 0.0f;
			size_t n = 0;
			foreach(ref cannon; Cannons)
			{
				cannon.CheckArc(Target, Position.Position, Orientation.Theta, MaxRange);
				if(cannon.On)
				{
					energy_usage += dt * BeamEnergy;
					
					if(energy_usage > Screen.GameMode.Energy)
					{
						cannon.On = false;
					}
					else
					{
						n++;
					}
				}
			}
			
			Screen.GameMode.Energy = Screen.GameMode.Energy - dt * n * BeamEnergy;
			
			if(n > 0)
			{
				Screen.Damage(Target, n, ColorVal);
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
	
	void SetColor(int color)
	{
		ColorVal.ColorFlag = color;
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
	
	SColor Selection()
	{
		return ColorVal;
	}
	
	SColor Selection(SColor color)
	{
		return ColorVal = color;
	}
	
	const(char)[] Name()
	{
		return "beam_cannon";
	}
protected:
	SColor ColorVal;
	
	SVector2D ScreenTargetVal;
}


