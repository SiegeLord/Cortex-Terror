/*
This file is part of Cortex Terror, a game of galactic exploration and domination.
Copyright (C) 2011 Pavel Sountsov

Cortex Terror is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cortex Terror is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cortex Terror. If not, see <http:#www.gnu.org/licenses/>.
*/

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
import engine.Sound;

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
		
		FireSoundName = config.Get!(const(char)[])(Name, "fire_sound", "");
		if(FireSoundName == "")
			throw new Exception("'" ~ Name.idup ~ "' component requires a 'fire_sound' entry in the '" ~ Name.idup ~ "' section of the configuration file.");
	}
	
	void LoadSounds(IGameMode game_mode)
	{
		FireSound = game_mode.SoundManager.Load(FireSoundName);
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
				
				if(Instance is null)
				{
					Instance = FireSound.Play(Position.Position, true);
					Instance.Busy = true;
				}
			}
			else if(Instance !is null)
			{
				StopSound;
			}
		}
		else
		{
			StopSound;
		}
		
		if(Instance !is null)
			Instance.Position = Position.Position;
	}
	
	void StopSound()
	{
		if(Instance !is null)
		{
			Instance.Busy = false;
			Instance.Playing = false;
			Instance = null;
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
	const(char)[] FireSoundName;
	CSound FireSound;
	CSampleInstance Instance;
	
	SColor ColorVal;
	
	SVector2D ScreenTargetVal;
}


