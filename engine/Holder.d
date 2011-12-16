module engine.Holder;

import engine.Disposable;

class CHolder(Type, alias Destructor) : CDisposable
{
	this(Type t)
	{
		Payload = t;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		Destructor(Payload);
		Payload = Type.init;
	}
	
	Type Get()
	{
		return Payload;
	}
	
	Type Set(Type t)
	{
		return Payload = t;
	}
	
protected:	
	Type Payload;
}
