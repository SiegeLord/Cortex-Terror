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

module game.components.PulseCannon;

import game.components.Cannon;
import game.components.Updatable;
import game.components.Position;
import game.components.Orientation;
import game.ITacticalScreen;
import game.IGameMode;
import game.Color;

import engine.Sound;
import engine.IComponentHolder;
import engine.MathTypes;
import engine.Config;
import engine.Util;
import game.IGameMode;

import tango.io.Stdout;

import allegro5.allegro;

class CPulseCannon : CCannon
{
	this(CConfig config)
	{
		super(config);
		Cooldown = config.Get!(float)(Name, "cooldown", 0.25);
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
		Heat -= dt;
		
		if(On)
		{
			bool any_on = false;
			foreach(ref cannon; Cannons)
			{
				cannon.CheckArcLead(Target, TargetVelocity, Position.Position, Orientation.Theta, MaxRange);
				any_on |= cannon.On;
			}
			
			if(any_on && Heat < 0)
			{
				Heat = Cooldown;
				FireSound.Play(Position.Position);
				
				foreach(cannon; Cannons)
				{
					auto world_location = cannon.GetWorldLocation(Position.Position, Orientation.Theta);
					Screen.FireBullet(world_location, cannon.Target);
				}
			}
		}
	}
	
	override
	const(char)[] Name()
	{
		return "pulse_cannon";
	}
	
	SVector2D TargetVelocity;
protected:
	const(char)[] FireSoundName;
	CSound FireSound;
	float Cooldown;
	float Heat = 0;
}



