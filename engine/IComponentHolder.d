module engine.IComponentHolder;

import engine.Component;

interface IComponentHolder
{
	CComponent GetComponent(ClassInfo type);
	/* Callback returns true if it wants more */
	void GetComponent(ClassInfo type, bool delegate(CComponent comp) callback);
	
	const(char)[] Name();
	CComponent[] Components();
}
