module game.GameMode;

import engine.Config;
import engine.ConfigManager;
import engine.MathTypes;
import engine.Util;
import engine.Font;
import engine.FontManager;
import engine.Bitmap;
import engine.BitmapManager;

import game.Mode;
import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.Galaxy;
import game.GalaxyScreen;
import game.StarSystem;
import game.Screen;
import game.TacticalScreen;

import allegro5.allegro;
import allegro5.allegro_primitives;

import tango.io.Stdout;
import tango.util.container.more.Stack;
import tango.math.random.Random;
import tango.math.Math;

const GalaxyRadius = 500;
const NumStars = 256;
const WarpConversionFactor = 4;

class CGameMode : CMode, IGameMode
{
	this(IGame game)
	{
		super(game);
		ConfigManager = new CConfigManager;
		FontManager = new CFontManager;
		UIFont = FontManager.Load("data/fonts/Energon.ttf", 24);
		BitmapManager = new CBitmapManager;
		UIBottomLeft = BitmapManager.Load("data/bitmaps/ui_bottom_left.png");
		Rand = new Random;
		Rand.seed({ return cast(int)(al_get_time() * 1000); });
		
		Galaxy = new CGalaxy(this, Rand, NumStars, GalaxyRadius);
		
		do
		{
			GalaxyLocation = SVector2D(Rand.uniformR2(GalaxyRadius / 3, GalaxyRadius / 2), 0);
			GalaxyLocation.Rotate(Rand.uniformR(2 * PI));
			
			CurrentStarSystem = Galaxy.GetStarSystemAt(GalaxyLocation);
		} while(CurrentStarSystem.HaveLifeforms);
		
		GalaxyLocation = CurrentStarSystem.Position;
		ScreenStack.push(new CGalaxyScreen(this));
	}
	
	override
	void Logic(float dt)
	{
		if(WantPop)
		{
			ScreenStack.top.Dispose;
			ScreenStack.pop;
			WantPop = false;
			if(ScreenStack.size == 0)
			{
				Game.NextMode = EMode.Exit;
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
				Arrived = true;
			}
			else
			{
				dir_to_dest.Normalize;
				GalaxyLocation = GalaxyLocation + dt * dir_to_dest * WarpSpeed;
				Energy = Energy - dt * WarpSpeed / WarpConversionFactor;
			}
		}
		
		ScreenStack.top.Update(dt);
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		ScreenStack.top.Draw(physics_alpha);
	}
	
	override
	void Input(ALLEGRO_EVENT* event)
	{
		ScreenStack.top.Input(event);
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				Game.NextMode = EMode.Exit;
				break;
			}
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
			CurrentStarSystemVal.Explored = true;
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
		
		const space = 15;
		
		auto health_arc = 3 * PI / 2 * Health / MaxHealth;
		auto energy_arc = 3 * PI / 2 * Energy / MaxEnergy;
		
		al_draw_arc(SideBarWidth / 2, screen_size.Y - SideBarWidth / 2, 65 - space, PI / 2, energy_arc, al_map_rgb_f(1, 1, 0), space * 2);
		al_draw_arc(SideBarWidth / 2, screen_size.Y - SideBarWidth / 2, 65 + space, PI / 2, health_arc, al_map_rgb_f(0, 0, 1), space * 2);
		al_draw_bitmap(UIBottomLeft.Get, 0, screen_size.Y - UIBottomLeft.Height, 0);
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
		return HealthVal = val;
	}
	
	mixin(Prop!("CGalaxy", "Galaxy", "override", "protected"));
	mixin(Prop!("SVector2D", "GalaxyLocation", "override", "protected"));
	mixin(Prop!("bool", "Arrived", "override", "protected"));
	mixin(Prop!("float", "WarpSpeed", "override", "override"));
	mixin(Prop!("CFont", "UIFont", "override", "protected"));
	mixin(Prop!("CBitmapManager", "BitmapManager", "override", "protected"));
	mixin(Prop!("CConfigManager", "ConfigManager", "override", "protected"));
	mixin(Prop!("float", "MaxHealth", "override", "protected"));
	mixin(Prop!("float", "MaxEnergy", "override", "protected"));
protected:
	CBitmap UIBottomLeft;

	float HealthVal = 100;
	float MaxHealthVal = 100;
	float EnergyVal = 25;
	float MaxEnergyVal = 50;

	CFont UIFontVal;
	CFontManager FontManager;
	
	CBitmapManager BitmapManagerVal;
	CConfigManager ConfigManagerVal;

	float WarpSpeedVal = 50;
	
	bool ArrivedVal = true;
	SVector2D SystemLocationVal;
	SVector2D GalaxyLocationVal;
	CGalaxy GalaxyVal;
	Stack!(CScreen) ScreenStack;
	bool WantPop = false;
	CStarSystem CurrentStarSystemVal;
	float GalaxyZoomVal = 1;
	Random Rand;
}
