module game.Game;

import engine.BitmapManager;
import engine.Gfx;
import engine.Disposable;
import engine.Config;
import engine.Util;

import game.IGame;
import game.Mode;
import game.MainMenuMode;

import tango.io.Stdout;

import allegro5.allegro;

class CGame : CDisposable, IGame
{
	this()
	{
		al_init();
		al_install_keyboard();
		al_install_mouse();
		
		Options = new CConfig("game.cfg");
		Gfx = new CGfx(Options);
		
		Queue = al_create_event_queue();
		al_register_event_source(Queue, al_get_keyboard_event_source());
		al_register_event_source(Queue, al_get_mouse_event_source());
		al_register_event_source(Queue, al_get_display_event_source(Gfx.Display));
		
		NextMode = EMode.MainMenu;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		
		al_destroy_event_queue(Queue);
		
		Gfx.Dispose;
		Options.Dispose;
	}
	
	void Run()
	{
		while(true)
		{
			scope(exit) if(Mode) Mode.Dispose;
			final switch(NextMode)
			{
				case EMode.MainMenu:
				{
					Mode = new CMainMenuMode(this);
					break;
				}
				case EMode.Exit:
					goto exit;
			}
			
			GameLoop(Mode);
		}
exit:{}
	}
	
	override
	void NextMode(EMode mode)
	{
		if(NextMode != mode)
			WantModeSwitch = true;
		
		NextModeVal = mode;
	}
	
	EMode NextMode()
	{
		return NextModeVal;
	}

	mixin(Prop!("float", "Time", "override", "protected"));
protected:
	void GameLoop(CMode mode)
	{
		ALLEGRO_EVENT event;
		Time = 0;
		
		float cur_time = al_get_time();
		float accumulator = 0;
		float physics_alpha = 0;
		
		while(1)
		{
			float new_time = al_get_time();
			float delta_time = new_time - cur_time;
			al_rest(FixedDt - delta_time);
			
			delta_time = new_time - cur_time;
			cur_time = new_time;

			accumulator += delta_time;

			while (accumulator >= FixedDt)
			{
				while(al_get_next_event(Queue, &event))
				{
					mode.Input(&event);
				}
				
				mode.Logic(FixedDt);
				
				if(WantModeSwitch)
					return;			
				
				//if(!Paused)
				Time = Time + FixedDt;
				accumulator -= FixedDt;
			}

			//if(Paused)
			//	physics_alpha = 0;
			//else
			physics_alpha = accumulator / FixedDt;
			
			mode.Draw(physics_alpha);
			
			al_flip_display();
		}
	}

	CMode Mode;
	EMode NextModeVal;
	bool WantModeSwitch = false;

	ALLEGRO_EVENT_QUEUE* Queue;
	enum FixedDt = 1.0f/60.0f;
	float TimeVal = 0.0f;
	
	CConfig Options;
	CGfx Gfx;
}
