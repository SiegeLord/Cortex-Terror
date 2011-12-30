module game.MainMenuMode;

import engine.FontManager;
import engine.Font;
import engine.SoundManager;
import engine.Sound;
import engine.MathTypes;

import game.Music;
import game.Mode;
import game.IGame;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

import tango.io.Stdout;
import tango.math.random.Random;
import tango.math.Math;

struct SStar
{
	void Draw(float physics_alpha, SVector2D center)
	{
		auto frac = min((Position - center).Length / 300, 1);
		
		al_draw_filled_rectangle(Position.X, Position.Y, Position.X + 2, Position.Y + 2, al_map_rgba_f(frac, frac, frac, frac));
	}
	
	void Update(float dt)
	{
		Position += Velocity * dt;
		Velocity *= 1.05;
	}
	
	SVector2D Position;
	SVector2D Velocity;
}

class CMainMenuMode : CMode
{
	this(IGame game)
	{
		super(game);
		FontManager = new CFontManager;
		Music = new CMusic(!Game.Options.Get!(bool)("sfx", "music", true));
		Font = FontManager.Load("data/fonts/Energon.ttf", 24);
		TitleFont = FontManager.Load("data/fonts/Energon.ttf", 48);
		Music.Play(EMusic.Medium);
		
		SoundManager = new CSoundManager;
		UISound = SoundManager.Load("data/sounds/gui.ogg");
		
		auto sz = Game.Gfx.ScreenSize;
		foreach(ref star; Stars)
		{
			star.Position.X = rand.uniformR(sz.X);
			star.Position.Y = rand.uniformR(sz.Y);
			
			star.Velocity = star.Position - sz / 2;
			star.Velocity *= 50 / star.Velocity.Length;
		}
		
		float t = 0;
		while(t < 5)
		{
			UpdateStars(FixedDt);
			t += FixedDt;
		}
	}
	
	void UpdateStars(float dt)
	{
		auto sz = Game.Gfx.ScreenSize;
		foreach(ref star; Stars)
		{
			star.Update(dt);
			if(star.Position.X < 0 || star.Position.Y < 0 || star.Position.X >= sz.X || star.Position.Y >= sz.Y)
			{
				star.Position.X = sz.X / 2;
				star.Position.Y = sz.Y / 2;
				
				auto theta = rand.uniformR(2 * PI);
				
				star.Velocity = SVector2D(50, 0);
				star.Velocity.Rotate(theta);
			}
		}
	}
	
	override
	void Logic(float dt)
	{
		UpdateStars(dt);
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		
		foreach(star; Stars)
			star.Draw(physics_alpha, Game.Gfx.ScreenSize / 2);
		
		auto mid = Game.Gfx.ScreenSize / 2 + SVector2D(0, 50);
		
		auto title_mid = Game.Gfx.ScreenSize / 2 - SVector2D(0, 70);
		
		auto select_color = al_map_rgb_f(1, 1, 1);
		auto normal_color = al_map_rgb_f(0.5, 1, 0.5);
		
		al_draw_text(Font.Get, CurChoice == 0 ? select_color : normal_color, mid.X, mid.Y - 45, ALLEGRO_ALIGN_CENTRE, "Continue Game");
		al_draw_text(Font.Get, CurChoice == 1 ? select_color : normal_color, mid.X, mid.Y, ALLEGRO_ALIGN_CENTRE, "New Game");
		al_draw_text(Font.Get, CurChoice == 2 ? select_color : normal_color, mid.X, mid.Y + 45, ALLEGRO_ALIGN_CENTRE, "Quit");
		
		al_draw_text(TitleFont.Get, al_map_rgb_f(0.5, 0.5, 1), title_mid.X, title_mid.Y, ALLEGRO_ALIGN_CENTRE, "Cortex Terror");
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				Game.NextMode = EMode.Exit;
				break;
			}
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
						Game.NextMode = EMode.Exit;
						break;
					case ALLEGRO_KEY_ENTER:
						if(CurChoice == 0)
						{
							Game.Load = true;
							Game.NextMode = EMode.Game;
						}
						else if(CurChoice == 1)
						{
							Game.Load = false;
							Game.NextMode = EMode.Game;
						}
						else
						{
							Game.NextMode = EMode.Exit;
						}
						break;
					case ALLEGRO_KEY_UP:
						CurChoice--;
						UISound.Play;
						
						if(CurChoice < 0)
							CurChoice = 2;
						break;
					case ALLEGRO_KEY_DOWN:
						CurChoice++;
						UISound.Play;
						
						if(CurChoice > 2)
							CurChoice = 0;
						break;
					default:
				}
				break;
			}
			default:
		}
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		FontManager.Dispose;
		SoundManager.Dispose;
		Music.Dispose;
	}
protected:
	SStar[100] Stars;
	
	int CurChoice = 0;
	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;
	CSoundManager SoundManager;
	CSound UISound;
	CMusic Music;
}
