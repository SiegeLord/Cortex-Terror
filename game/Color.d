module game.Color;

enum EColor : int
{
	Red = 1,
	Green = 2,
	Blue = 4
}

struct SColor
{
	const
	bool Check(EColor color)
	{
		return (ColorFlag & color) != 0;
	}
	
	bool Toggle(EColor color)
	{
		ColorFlag ^= color;
		if(ColorFlag == 0)
			ColorFlag |= color;
		
		return Check(color);
	}
	
	void TurnOn(EColor color)
	{
		ColorFlag |= color;
	}
	
	int ColorFlag = EColor.Red;
}
