module game.StarField;

import game.IGameMode;

import engine.MathTypes;

import tango.math.random.Random;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CStarField
{
	this(IGameMode game_mode, SVector2D ini_offset, float zoom_fraction, size_t num_stars)
	{
		GameMode = game_mode;
		ZoomFraction = zoom_fraction;
		
		Stars.length = num_stars;
		
		auto sz = GameMode.Game.Gfx.ScreenSize / zoom_fraction;
		
		foreach(ref star; Stars)
		{
			star.X = ini_offset.X + rand.uniformR2(0.0f, sz.X);
			star.Y = ini_offset.Y + rand.uniformR2(0.0f, sz.Y);
		}
	}
	
	void Draw(SVector2D offset, float physics_alpha)
	{
		foreach(star; Stars)
		{
			auto screen_pos = (star - offset) * ZoomFraction;
			al_draw_filled_rectangle(screen_pos.X, screen_pos.Y, screen_pos.X + 2, screen_pos.Y + 2, al_map_rgb_f(0.25, 0.25, 0.3));
		}
	}
	
	void Update(SVector2D offset)
	{
		auto sz = GameMode.Game.Gfx.ScreenSize;
		
		foreach(ref star; Stars)
		{
			auto screen_pos = (star - offset) * ZoomFraction;
			
			if(screen_pos.X < 0)
				screen_pos.X = sz.X;
			
			if(screen_pos.X > sz.X)
				screen_pos.X = 0;
			
			if(screen_pos.Y < 0)
				screen_pos.Y = sz.Y;
			
			if(screen_pos.Y > sz.Y)
				screen_pos.Y = 0;
			
			star = (screen_pos / ZoomFraction + offset);
		}
	}
protected:
	IGameMode GameMode;
	float ZoomFraction;
	SVector2D[] Stars;
}
