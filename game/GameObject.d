module game.GameObject;

import engine.ComponentHolder;
import engine.Component;
import engine.Config;

import game.components.Updatable;
import game.components.Drawable;
import game.components.ComponentFactory;

class CGameObject : CComponentHolder
{
	this(CConfig config)
	{
		auto components = config.Get!(const(char)[][])("", "components", null);
		foreach(component; components)
		{
			AddComponent(CreateComponent(component));
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
}
