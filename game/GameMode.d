module game.GameMode;

import engine.Config;
import engine.ConfigManager;
import engine.MathTypes;
import engine.Util;
import engine.Font;
import engine.FontManager;
import engine.BitmapManager;

import game.Mode;
import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.Galaxy;
import game.GalaxyScreen;
import game.StarSystem;
import game.SystemScreen;
import game.Screen;
import game.TacticalScreen;

import allegro5.allegro;

import tango.io.Stdout;
import tango.util.container.more.Stack;
import tango.math.random.Random;
import tango.math.Math;

const GalaxyRadius = 500;
const NumStars = 256;

class CGameMode : CMode, IGameMode
{
	this(IGame game)
	{
		super(game);
		ConfigManager = new CConfigManager;
		FontManager = new CFontManager;
		UIFont = FontManager.Load("data/fonts/Energon.ttf", 24);
		BitmapManager = new CBitmapManager;
		Rand = new Random;
		Rand.seed({ return cast(int)(al_get_time() * 1000); });
		
		Galaxy = new CGalaxy(this, Rand, NumStars, GalaxyRadius);
		
		GalaxyLocation = SVector2D(Rand.uniformR2(GalaxyRadius / 3, GalaxyRadius / 2), 0);
		GalaxyLocation.Rotate(Rand.uniformR(2 * PI));
		
		CurrentStarSystem = Galaxy.GetStarSystemAt(GalaxyLocation);
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
			{
				
			}
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
			case EScreen.System:
			{
				new_screen = new CSystemScreen(this);
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
	
	mixin(Prop!("CGalaxy", "Galaxy", "override", "protected"));
	mixin(Prop!("SVector2D", "GalaxyLocation", "override", "protected"));
	mixin(Prop!("bool", "Arrived", "override", "protected"));
	mixin(Prop!("float", "WarpSpeed", "override", "override"));
	mixin(Prop!("float", "WarpRange", "override", "override"));
	mixin(Prop!("CFont", "UIFont", "override", "protected"));
	mixin(Prop!("CBitmapManager", "BitmapManager", "override", "protected"));
	mixin(Prop!("CConfigManager", "ConfigManager", "override", "protected"));
protected:
	CFont UIFontVal;
	CFontManager FontManager;
	
	CBitmapManager BitmapManagerVal;
	CConfigManager ConfigManagerVal;

	float WarpSpeedVal = 50;
	float WarpRangeVal = 50;
	
	bool ArrivedVal = true;
	SVector2D GalaxyLocationVal;
	CGalaxy GalaxyVal;
	Stack!(CScreen) ScreenStack;
	bool WantPop = false;
	CStarSystem CurrentStarSystemVal;
	float GalaxyZoomVal = 1;
	Random Rand;
}
