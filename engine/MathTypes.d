module engine.MathTypes;

import tango.math.Math;
import tango.math.IEEE;
import tango.io.Stdout;

struct SVector2D
{
	float X = 0;
	float Y = 0;
	
	void Set(float x, float y)
	{
		X = x;
		Y = y;
	}

	SVector2D Rotate(float cosine, float sine)
	{
		auto t = X * cosine - Y * sine;
		Y = X * sine + Y * cosine;
		X = t;
		
		return this;
	}
	
	SVector2D Rotate(float theta)
	{
		return Rotate(cos(theta), sin(theta));
	}
	
	//rotates this vector by pi/2
	SVector2D MakeNormal()
	{
		float t = Y;
		Y = X;
		X = -t;
		
		return this;
	}
	
	float DotProduct(SVector2D other)
	{
		return X * other.X + Y * other.Y;
	}
	
	float CrossProduct(SVector2D other)
	{
		return X * other.Y - Y * other.X;
	}
	
	float Length()
	{
		return hypot(X, Y);
	}
	
	float LengthSq()
	{
		return X * X + Y * Y;
	}
	
	SVector2D opBinary(immutable(char)[] op)(SVector2D other)
	{
		mixin("return SVector2D(X " ~ op ~ "other.X, Y " ~ op ~ "other.Y);");
	}
	
	SVector2D opBinary(immutable(char)[] op)(float scalar)
	{
		mixin("return SVector2D(X " ~ op ~ "scalar, Y " ~ op ~ "scalar);");
	}
	
	SVector2D opBinaryRight(immutable(char)[] op)(float scalar)
	{
		mixin("return SVector2D(X " ~ op ~ "scalar, Y " ~ op ~ "scalar);");
	}
	
	void opOpAssign(immutable(char)[] op)(SVector2D other)
	{
		mixin("X " ~ op ~ "= other.X; Y " ~ op ~ "= other.Y;");
	}
	
	void opOpAssign(immutable(char)[] op)(float scalar)
	{
		mixin("X " ~ op ~ "= scalar; Y " ~ op ~ "= scalar;");
	}
	
	bool opEquals(SVector2D other)
	{
		return feqrel(X, other.X) && feqrel(Y, other.Y);
	}

	SVector2D opUnary(immutable(char)[] op)() if(op == "-")
	{
		return SVector2D(-X, -Y);
	}

	SVector2D Normalize()
	{
		this /= Length;
		return this;
	}
	
	float opIndex(size_t i)
	{
		if(i == 0)
			return X;
		else
			return Y;	
	}
	
	float opIndexAssign(float val, size_t i)
	{
		if(i == 0)
		{
			X = val;
			return X;
		}
		else
		{
			Y = val;
			return Y;
		}
	}
}

unittest
{
	SVector2D vec;
	vec.Set(0, 0);
	vec += SVector2D(1, 2);
	assert(vec == SVector2D(1, 2));
}
