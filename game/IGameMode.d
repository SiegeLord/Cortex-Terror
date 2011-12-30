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

module game.IGameMode;

import game.IGame;
import game.Galaxy;
import game.StarSystem;
import game.Color;
import game.Music;

import engine.Font;
import engine.MathTypes;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.SoundManager;
import engine.Sound;

const SideBarWidth = 200;

enum EScreen
{
	Intro,
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
	
	CMusic Music();
	
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
	
	bool FirstMessagePlayed();
	bool FirstMessagePlayed(bool val);
	
	bool FastEndGame();
}
