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

module game.components.ComponentFactory;

import engine.Component;
import engine.Config;

import game.components.Position;
import game.components.Physics;
import game.components.Rectangle;
import game.components.Star;
import game.components.Orientation;
import game.components.Engine;
import game.components.Sprite;
import game.components.Controller;
import game.components.AIController;
import game.components.Planet;
import game.components.BeamCannon;
import game.components.PulseCannon;
import game.components.Beam;
import game.components.Damageable;
import game.components.Shield;
import game.components.ShieldRotator;
import game.components.Ship;

alias CComponent function(CConfig config) Creator;

Creator[char[]] Creators;

CComponent CreatorFunc(T)(CConfig config)
{
	return new T(config);
}

CComponent CreateComponent(CConfig config, const(char)[] name)
{
	auto creator_ptr = name in Creators;
	if(creator_ptr is null)
		throw new Exception(name.idup ~ " is not a valid component");
	return (*creator_ptr)(config);
}

static this()
{
	Creators["position"] = &CreatorFunc!(CPosition);
	Creators["position"] = &CreatorFunc!(CPosition);
	Creators["physics"] = &CreatorFunc!(CPhysics);
	Creators["rectangle"] = &CreatorFunc!(CRectangle);
	Creators["star"] = &CreatorFunc!(CStar);
	Creators["orientation"] = &CreatorFunc!(COrientation);
	Creators["engine"] = &CreatorFunc!(CEngine);
	Creators["sprite"] = &CreatorFunc!(CSprite);
	Creators["controller"] = &CreatorFunc!(CController);
	Creators["planet"] = &CreatorFunc!(CPlanet);
	Creators["beam_cannon"] = &CreatorFunc!(CBeamCannon);
	Creators["beam"] = &CreatorFunc!(CBeam);
	Creators["damageable"] = &CreatorFunc!(CDamageable);
	Creators["shield"] = &CreatorFunc!(CShield);
	Creators["ai_controller"] = &CreatorFunc!(CAIController);
	Creators["pulse_cannon"] = &CreatorFunc!(CPulseCannon);
	Creators["shield_rotator"] = &CreatorFunc!(CShieldRotator);
	Creators["ship"] = &CreatorFunc!(CShip);
}
