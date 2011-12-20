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
import game.components.Planet;
import game.components.BeamCannon;
import game.components.Beam;

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
}
