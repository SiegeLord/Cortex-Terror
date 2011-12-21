module game.components.PulseCannon;

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

import tango.io.Stdout;

import allegro5.allegro;

class CPulseCannon : CCannon
{
	this(CConfig config)
	{
		super(config);
		Cooldown = config.Get!(float)(Name, "cooldown", 0.25);
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
				cannon.CheckArc(Target, Position.Position, Orientation.Theta, MaxRange);
				any_on |= cannon.On;
			}
			
			if(any_on && Heat < 0)
			{
				Heat = Cooldown;
				
				foreach(cannon; Cannons)
				{
					Screen.FireBullet(cannon.GetWorldLocation(Position.Position, Orientation.Theta));
				}
			}
		}
	}
	
	override
	const(char)[] Name()
	{
		return "pulse_cannon";
	}
protected:
	float Cooldown;
	float Heat = 0;
}



