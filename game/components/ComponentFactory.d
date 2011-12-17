module game.components.ComponentFactory;

import engine.Component;

import game.components.Position;
import game.components.Physics;
import game.components.Rectangle;

typedef CComponent function() Creator;

Creator[char[]] Creators;

CComponent CreatorFunc(T)()
{
	return new T;
}

CComponent CreateComponent(const(char)[] name)
{
	auto creator_ptr = name in Creators;
	if(creator_ptr is null)
		throw new Exception(name.idup ~ " is not a valid component");
	return (*creator_ptr)();
}

static this()
{
	Creators["position"] = &CreatorFunc!(CPosition);
	Creators["physics"] = &CreatorFunc!(CPhysics);
	Creators["rectangle"] = &CreatorFunc!(CRectangle);
}
