module game.IGameMode;

import game.IGame;
import game.Galaxy;
import game.StarSystem;
import game.Color;

import engine.Font;
import engine.MathTypes;
import engine.BitmapManager;
import engine.ConfigManager;

const SideBarWidth = 200;

enum EScreen
{
	Galaxy,
	Tactical
}

enum EBonus
{
	Health,
	Energy,
	RedBeam,
	GreenBeam,
	BlueBeam,
	None
}

interface IGameMode
{
	SVector2D GalaxyLocation();
	SVector2D ToGalaxyView(SVector2D galaxy_pos);
	SVector2D FromGalaxyView(SVector2D galaxy_view);
	
	float GalaxyZoom();
	float GalaxyZoom(float new_zoom);
	float WarpSpeed(float new_speed);
	float WarpSpeed();
	
	float Health();
	float Health(float new_health);
	float MaxHealth();
	float Energy();
	float Energy(float new_energy);
	float MaxEnergy();
	void AddBonus(EBonus bonus);
	
	bool Color(EColor color);
	
	bool Arrived();
	IGame Game();
	CGalaxy Galaxy();
	void PushScreen(EScreen screen);
	void PopScreen();
	CStarSystem CurrentStarSystem();
	CStarSystem CurrentStarSystem(CStarSystem new_star_system);
	CFont UIFont();
	CBitmapManager BitmapManager();
	CConfigManager ConfigManager();
	void DrawLeftSideBar(float physics_alpha);
}
