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

module game.GameObject;

import engine.ComponentHolder;
import engine.Component;
import engine.Config;

import game.components.Updatable;
import game.components.Drawable;
import game.components.ComponentFactory;
import game.IGameMode;

class CGameObject : CComponentHolder
{
	this(IGameMode game_mode, const(char)[] name)
	{
		GameMode = game_mode;
		auto config = GameMode.ConfigManager.Load("data/objects/" ~ name ~ ".cfg");
		auto components = config.Get!(const(char)[][])("", "components", null);
		foreach(component; components)
		{
			AddComponent(CreateComponent(config, component));
		}
		Updatables = new typeof(Updatables)();
		Drawables = new typeof(Drawables)();
		WireUp();
	}
	
	override
	void WireUp()
	{
		super.WireUp();
		Updatables.WireUp(this);
		Drawables.WireUp(this);
	}
	
	void Update(float dt)
	{
		Updatables.Update(dt);
	}
	
	void Draw(float physics_alpha)
	{
		Drawables.Draw(physics_alpha);
	}
protected:
	CComponentGroup!(CUpdatable) Updatables;
	CComponentGroup!(CDrawable) Drawables;
	IGameMode GameMode;
}
