module game.GameObject;

import engine.ComponentHolder;
import engine.Component;
import game.components.Updatable;
import game.components.Drawable;

class CGameObject : CComponentHolder
{
	this()
	{
		Updatables = new typeof(Updatables)();
		Drawables = new typeof(Drawables)();
		//WireUp();
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
