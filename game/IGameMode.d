module game.IGameMode;

import game.IGame;
import game.Galaxy;
import game.StarSystem;
import game.Color;

import engine.Font;
import engine.MathTypes;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.SoundManager;
import engine.Sound;

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
	
	bool DisplayFinalMessage();
	bool DisplayFinalMessage(bool val);
	
	int RacesLeft();
	int RacesLeft(int new_sys);
	
	void AddBonus(EBonus bonus);
	
	SColor BeamSelection();
	SColor BeamSelection(SColor new_sel);
	
	bool Color(int color);
	
	bool Arrived();
	IGame Game();
	CGalaxy Galaxy();
	void PushScreen(EScreen screen);
	void PopScreen();
	CStarSystem CurrentStarSystem();
	CStarSystem CurrentStarSystem(CStarSystem new_star_system);
	CFont UIFont();
	CSound UISound();
	CBitmapManager BitmapManager();
	CConfigManager ConfigManager();
	CSoundManager SoundManager();
	void DrawLeftSideBar(float physics_alpha);
	
	void ClearMessages();
	void AddMessage(const(char)[] str, bool fade_out = true, float duration = 15, bool main = true);
}
