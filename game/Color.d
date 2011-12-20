module game.Color;

import allegro5.allegro;

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
	
	const
	ALLEGRO_COLOR ToColor()
	{
		auto color = al_map_rgb_f(0, 0, 0);
		if(Check(EColor.Red))
			color.r = 1;
		if(Check(EColor.Green))
			color.g = 1;
		if(Check(EColor.Blue))
			color.b = 1;
		return color;
	}
	
	const
	bool opEquals(SColor other)
	{
		return other.ColorFlag == ColorFlag;
	}
	
	int ColorFlag = EColor.Red;
}
