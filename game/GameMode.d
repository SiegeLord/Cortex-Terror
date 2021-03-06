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

module game.GameMode;

import engine.Config;
import engine.ConfigManager;
import engine.MathTypes;
import engine.Util;
import engine.Font;
import engine.FontManager;
import engine.Bitmap;
import engine.BitmapManager;
import engine.SoundManager;
import engine.Sound;

import game.Mode;
import game.Color;
import game.Music;
import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.Galaxy;
import game.GalaxyScreen;
import game.IntroScreen;
import game.Message;
import game.StarSystem;
import game.Screen;
import game.TacticalScreen;
import game.components.BeamCannon;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import tango.io.Stdout;
import tango.text.convert.Format;
import tango.util.container.more.Stack;
import tango.math.random.Random;
import tango.math.Math;
import tango.time.Clock;

const GalaxyRadius = 500;
const NumStars = 256;
const WarpConversionFactor = 0.25f;
const HealthRate = 0.03f; /* Frac of max */
const HealthConversionFactor = 0.5f;

class CGameMode : CMode, IGameMode
{
	this(IGame game, bool load)
	{
		super(game);
		SoundManager = new CSoundManager;
		UISound = SoundManager.Load("data/sounds/gui.ogg");
		Message1 = SoundManager.Load("data/sounds/message1.ogg");
		Message2 = SoundManager.Load("data/sounds/message2.ogg");
		ConfigManager = new CConfigManager;
		FontManager = new CFontManager;
		UIFont = FontManager.Load("data/fonts/Energon.ttf", 24);
		BitmapManager = new CBitmapManager;
		UIBottomLeft = BitmapManager.Load("data/bitmaps/ui_bottom_left.png");
		Rand = new Random;
		
		Music = new CMusic(!Game.Options.Get!(bool)("sfx", "music", true));
		
		auto config = new CConfig("save.cfg");
		scope(exit) config.Dispose;
		
		if(load)
		{		
			bool is_def;
			Seed = config.Get!(int)("", "seed", 0, &is_def);
			if(is_def)
				load = false;
		}
		else
		{
			Seed = cast(int)Clock.now.ticks;
		}
		
		if(load)
			FastEndGame = config.Get!(bool)("", "fast_end_game", false);
		else
			FastEndGame = Game.Options.Get!(bool)("game", "fast_end_game", false);
		
		if(FastEndGame)
		{
			ColorVal = SColor(EColor.Green | EColor.Red | EColor.Blue);
			HealthBonusCount = 3;
			EnergyBonusCount = 3;
			Health = MaxHealth;
			Energy = MaxEnergy / 2;
		}
		
		Rand.seed({ return Seed; });
		
		Galaxy = new CGalaxy(this, Rand, NumStars, GalaxyRadius);
		
		if(load)
		{
			CurrentStarSystem = Galaxy.GetStarSystem(config.Get!(size_t)("", "star_system_idx", 0));
			RacesLeft = config.Get!(int)("", "races_left", 0);
			BeamSelection = SColor(config.Get!(int)("", "beam_selection", EColor.Red));
			ColorVal.ColorFlag = config.Get!(int)("", "color", EColor.Red);
			Energy = config.Get!(float)("", "energy", 0);
			HealthBonusCount = config.Get!(int)("", "health_bonus", 0);
			EnergyBonusCount = config.Get!(int)("", "energy_bonus", 0);
			GalaxyZoom = config.Get!(float)("", "galaxy_zoom", 1);
			Health = MaxHealth;

			Galaxy.Load(config);

			FirstMessagePlayed = true;
		}
		else
		{
			CStarSystem sys;
			while(true)
			{
				auto vec = SVector2D(Rand.uniformR2(0, GalaxyRadius / 3), 0);
				vec.Rotate(Rand.uniformR2(0.0f, cast(float)(2.0f * PI)));
				GalaxyLocation = vec;
				
				sys = Galaxy.GetStarSystemAt(GalaxyLocation);
				if(!sys.HaveLifeforms)
					break;
			}
			CurrentStarSystem = sys;
		}
		
		GalaxyLocation = CurrentStarSystem.Position;
		PushScreen(EScreen.Galaxy);
		if(!load)
		{
			PushScreen(EScreen.Tactical);
			PushScreen(EScreen.Intro);
		}
		
		Save;
	}
	
	void Save()
	{
		auto config = new CConfig;
		scope(exit) config.Dispose;
		
		config.Set("", "seed", Seed);
		config.Set("", "star_system_idx", CurrentStarSystem.Index);
		config.Set("", "races_left", RacesLeft);
		config.Set("", "beam_selection", BeamSelection.ColorFlag);
		config.Set("", "color", ColorVal.ColorFlag);
		config.Set("", "energy", Energy);
		config.Set("", "health_bonus", HealthBonusCount);
		config.Set("", "energy_bonus", EnergyBonusCount);
		config.Set("", "galaxy_zoom", GalaxyZoom);
		config.Set("", "fast_end_game", FastEndGame);
		
		Galaxy.Save(config);
		
		config.Save("save.cfg");
	}
	
	override
	void Logic(float dt)
	{			
		if(Messages.length)
		{
			Messages[CurMessage].Update(dt);
			if(Messages[CurMessage].Done)
			{
				CurMessage++;
				if(CurMessage == Messages.length)
				{
					Messages.length = 0;
					CurMessage = 0;
				}
				else
				{
					Messages[CurMessage].StartSound;
				}
			}
		}
		
		if(WantPop)
		{
			ScreenStack.top.Dispose;
			ScreenStack.pop;
			WantPop = false;
			if(ScreenStack.size == 0 || Dead)
			{
				Game.NextMode = EMode.MainMenu;
				if(!Dead)
					Save;
				return;
			}
		}
		
		if(!Arrived)
		{
			auto dir_to_dest = CurrentStarSystem.Position - GalaxyLocation;
			auto len_sq = dir_to_dest.LengthSq;
			if(len_sq < WarpSpeed * WarpSpeed * dt * dt)
			{
				GalaxyLocation = CurrentStarSystem.Position;
				CurrentStarSystem.Visited = true;
				Arrived = true;
				if(!Dead)
					Save;
			}
			else
			{
				dir_to_dest.Normalize;
				GalaxyLocation = GalaxyLocation + dt * dir_to_dest * WarpSpeed;
				Energy = Energy - dt * WarpSpeed * WarpConversionFactor;
			}
		}
		
		if(!Dead && Health - MaxHealth)
		{
			auto old_health = Health;
			auto energy_use = HealthRate * MaxHealth * dt * HealthConversionFactor;
			
			if(energy_use > Energy)
				energy_use = Energy;
			auto health_bonus = energy_use / HealthConversionFactor;

			Health = Health + health_bonus;
			auto actual_energy_use = (Health - old_health) * HealthConversionFactor;
			Energy = Energy - actual_energy_use;
		}
		
		ScreenStack.top.Update(dt);
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		ScreenStack.top.Draw(physics_alpha);
		if(Messages.length)
			Messages[CurMessage].Draw(physics_alpha);
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		ScreenStack.top.Input(event);
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
				if(event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
				{
					Game.NextMode = EMode.MainMenu;
					if(!Dead && ScreenStack.size == 1)
						Save;
				}
				break;
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
				Game.NextMode = EMode.Exit;
				if(!Dead && ScreenStack.size == 1)
					Save;
				break;
			default:
		}
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		Galaxy.Dispose;
		ConfigManager.Dispose;
		FontManager.Dispose;
		BitmapManager.Dispose;
		SoundManager.Dispose;
		Music.Dispose;
		
		while(ScreenStack.size > 0)
		{
			ScreenStack.top.Dispose;
			ScreenStack.pop;
		}
	}
	
	override
	IGame Game()
	{
		return CMode.Game;
	}
	
	override
	float GalaxyZoom()
	{
		return GalaxyZoomVal;
	}
	
	override
	float GalaxyZoom(float new_zoom)
	{
		if(new_zoom < 0.25)
			new_zoom = 0.25;
		
		return GalaxyZoomVal = new_zoom;
	}
	
	override
	SVector2D ToGalaxyView(SVector2D galaxy_pos)
	{
		return (galaxy_pos - GalaxyLocation) * GalaxyZoom + Game.Gfx.ScreenSize / 2;
	}
	
	override
	SVector2D FromGalaxyView(SVector2D galaxy_view)
	{
		return (galaxy_view - Game.Gfx.ScreenSize / 2) / GalaxyZoom + GalaxyLocation;
	}
	
	override
	CStarSystem CurrentStarSystem(CStarSystem new_star_system)
	{
		if(Arrived)
		{
			Arrived = false;
			CurrentStarSystemVal = new_star_system;
			CurrentStarSystemVal.Scanned = true;
		}
		return CurrentStarSystemVal;
	}
	
	override
	CStarSystem CurrentStarSystem()
	{
		return CurrentStarSystemVal;
	}
	
	override
	void PushScreen(EScreen screen)
	{
		CScreen new_screen;
		final switch(screen)
		{
			case EScreen.Intro:
			{
				new_screen = new CIntroScreen(this);
				break;
			}
			case EScreen.Galaxy:
			{
				new_screen = new CGalaxyScreen(this);
				break;
			}
			case EScreen.Tactical:
			{
				new_screen = new CTacticalScreen(this);
				break;
			}
		}
		ScreenStack.push(new_screen);
	}
	
	override
	void PopScreen()
	{
		WantPop = true;
	}
	
	override
	void DrawLeftSideBar(float physics_alpha)
	{
		auto screen_size = Game.Gfx.ScreenSize;
		
		al_draw_bitmap(UIBottomLeft.Get, 0, screen_size.Y - UIBottomLeft.Height, 0);
		
		auto lh = 5 + UIFont.Height;
		auto x = 10;
		auto y = screen_size.Y - SideBarWidth - 4 * lh;
		
		al_draw_text(UIFont.Get, al_map_rgb_f(0.5, 0.5, 1), x + 25, y, 0, Format("{}\0", HealthBonusCount).ptr);
		al_draw_text(UIFont.Get, al_map_rgb_f(0.5, 0.5, 1), x + 25, y + lh, 0, Format("{}\0", EnergyBonusCount).ptr);
		
		const space = 15;
		
		auto health_arc = 3 * PI / 2 * Health / MaxHealth;
		auto energy_arc = 3 * PI / 2 * Energy / MaxEnergy;
		
		al_draw_arc(SideBarWidth / 2, screen_size.Y - SideBarWidth / 2, 65 - space, PI / 2, energy_arc, al_map_rgb_f(1, 1, 0), space);
		al_draw_arc(SideBarWidth / 2, screen_size.Y - SideBarWidth / 2, 65 + space, PI / 2, health_arc, al_map_rgb_f(0, 0, 1), space);
		
		y = screen_size.Y - SideBarWidth - 6 * lh;
		
		foreach(ii; 1..8)
		{
			int color = [1, 2, 4, 3, 5, 6, 7][ii - 1];
			al_draw_text(UIFont.Get, Color(color) ? SColor(color).ToColor : al_map_rgb_f(0.5, 0.5, 0.5), x, y, 0, 
			    Format("{}{}\0", BeamSelection.ColorFlag == color ? " " : "", ii).ptr);
			y -= lh;
		}
		
		al_draw_text(UIFont.Get, al_map_rgb_f(0.5, 0.5, 1), x, y, 0, "Beams");
	}
	
	override
	float Energy()
	{
		return EnergyVal;
	}
	
	override
	float Energy(float val)
	{
		if(val > MaxEnergy)
			val = MaxEnergy;
		if(val < 0)
			val = 0;
		return EnergyVal = val;
	}
	
	override
	float Health()
	{
		return HealthVal;
	}
	
	override
	float Health(float val)
	{
		if(val > MaxHealth)
			val = MaxHealth;
		if(val <= 0)
		{
			Dead = true;
			val = 0;
		}
		return HealthVal = val;
	}
	
	override
	float MaxEnergy()
	{
		return BaseEnergy + EnergyBonusCount * 25;
	}
	
	override
	float MaxHealth()
	{
		return BaseHealth + HealthBonusCount * 25;
	}
	
	override
	void AddBonus(EBonus bonus)
	{
		final switch(bonus)
		{
			case EBonus.Health:
				AddMessage("The technology on this world made my body become more durable.");
				
				auto old_max_health = MaxHealth;
				HealthBonusCount++;
				auto new_max_health = MaxHealth;
				Health = Health + new_max_health - old_max_health;
				break;
			case EBonus.Energy:
				AddMessage("The technology on this world made my energy storage more efficient.");
			
				EnergyBonusCount++;
				break;
			case EBonus.RedBeam:
				if(ColorVal.Check(EColor.Red))
					AddMessage("The technology on this world is already in my possession. I must continue my search.");
				else
					AddMessage("I have assimilated the laser beam technology; it will be most useful.");
			
				ColorVal.TurnOn(EColor.Red);
				break;
			case EBonus.GreenBeam:
				if(ColorVal.Check(EColor.Green))
					AddMessage("The technology on this world is already in my possession. I must continue my search.");
				else
					AddMessage("I have assimilated the anti-proton beam technology; it will be most useful.");
			
				ColorVal.TurnOn(EColor.Green);
				break;
			case EBonus.BlueBeam:
				if(ColorVal.Check(EColor.Blue))
					AddMessage("The technology on this world is already in my possession. I must continue my search.");
				else
					AddMessage("I have assimilated the graviton beam technology; it will be most useful.");
			
				ColorVal.TurnOn(EColor.Blue);
				break;
			case EBonus.None:
				break;
		}
	}
	
	override
	bool Color(int color)
	{
		return ColorVal.Check(color);
	}
	
	override
	void AddMessage(const(char)[] str, bool fade_out = true, float duration = 10, bool main = true)
	{
		if(Messages.length && Messages[$-1].Message == str)
			return;
		
		Messages ~= new CMessage(this, main ? al_map_rgb_f(0, 1, 0) : al_map_rgb_f(1, 0, 0),
		    main ? Message1 : Message2,
		    main ? "data/bitmaps/face.png" : "data/bitmaps/elephant.png", str, fade_out, duration);
		
		if(Messages.length == 1)
			Messages[0].StartSound;
	}
	
	override
	void ClearMessages()
	{
		Messages.length = 0;
		CurMessage = 0;
	}
	
	mixin(Prop!("CGalaxy", "Galaxy", "override", "protected"));
	mixin(Prop!("CSoundManager", "SoundManager", "override", "protected"));
	mixin(Prop!("SVector2D", "GalaxyLocation", "override", "protected"));
	mixin(Prop!("bool", "DisplayFinalMessage", "override", "override"));
	mixin(Prop!("bool", "Arrived", "override", "protected"));
	mixin(Prop!("float", "WarpSpeed", "override", "override"));
	mixin(Prop!("CFont", "UIFont", "override", "protected"));
	mixin(Prop!("CSound", "UISound", "override", "protected"));
	mixin(Prop!("CBitmapManager", "BitmapManager", "override", "protected"));
	mixin(Prop!("CConfigManager", "ConfigManager", "override", "protected"));
	mixin(Prop!("SColor", "BeamSelection", "override", "override"));
	mixin(Prop!("int", "RacesLeft", "override", "override"));
	mixin(Prop!("CMusic", "Music", "override", "protected"));
	mixin(Prop!("bool", "FirstMessagePlayed", "override", "override"));
	mixin(Prop!("bool", "FastEndGame", "override", "protected"));
protected:
	int RacesLeftVal;
	SColor BeamSelectionVal;
	SColor ColorVal;
		
	CBitmap UIBottomLeft;

	bool DisplayFinalMessageVal = false;
	bool Dead = false;
	float HealthVal = 100;
	float BaseHealth = 100;
	float EnergyVal = 25;
	float BaseEnergy = 50;
	int HealthBonusCount = 0;
	int EnergyBonusCount = 0;

	CFont UIFontVal;
	CFontManager FontManager;
	
	CBitmapManager BitmapManagerVal;
	CConfigManager ConfigManagerVal;
	
	CSound UISoundVal;
	CSound Message1;
	CSound Message2;
	CSoundManager SoundManagerVal;

	float WarpSpeedVal = 50;
	
	bool ArrivedVal = true;
	SVector2D SystemLocationVal;
	SVector2D GalaxyLocationVal;
	CGalaxy GalaxyVal;
	Stack!(CScreen) ScreenStack;
	
	size_t CurMessage = 0;
	CMessage[] Messages;
	
	CMusic MusicVal;
	
	bool WantPop = false;
	CStarSystem CurrentStarSystemVal;
	float GalaxyZoomVal = 1.5;
	Random Rand;
	int Seed;
	
	bool FirstMessagePlayedVal = false;
	
	bool FastEndGameVal = false;
}
