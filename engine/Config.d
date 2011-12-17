module engine.Config;

import engine.Holder;

import allegro5.allegro;

import tango.stdc.stringz;
import tango.core.Exception;
import tango.util.Convert;
import tr = tango.core.Traits;
import tango.text.Util;

class CConfig : CHolder!(ALLEGRO_CONFIG*, al_destroy_config)
{
	this(ALLEGRO_CONFIG* config)
	{
		super(config);
	}
	
	this()
	{
		this(al_create_config());
	}
	
	this(const(char)[] filename)
	{
		char[256] buf;
		auto config = al_load_config_file(toStringz(filename, buf));
		if(config is null)
			config = al_create_config();
		
		this(config);
	}
	
	T Get(T)(const(char)[] section, const(char)[] key, T def = T.init, bool* is_def = null)
	{
		char[256] buf1, buf2;
		auto value_ptr = al_get_config_value(Payload, toStringz(section, buf1), toStringz(key, buf2));
		
		if(value_ptr is null)
		{
			if(is_def !is null)
			{
				*is_def = true;
			}
			return def;
		}

		if(is_def !is null)
		{
			*is_def = false;
		}
		
		auto str = fromStringz(value_ptr);
		static if(tr.isArrayType!(T) && !tr.isStringType!(T))
		{
			alias tr.ElementTypeOfArray!(T) E;
			E[] ret;
			foreach(segment; delimiters(str, " \t"))
			{
				ret ~= to!(E)(segment);
			}
			return ret;
		}
		else
		{
			return to!(T)(str);
		}
	}
	
	void Set(T)(const(char)[] section, const(char)[] key, T val)
	{
		char[256] buf1, buf2, buf3;
		const(char)[] str;
		static if(tr.isArrayType!(T) && !tr.isStringType!(T))
		{
			foreach(e; val)
			{
				str ~= to!(const(char)[])(e) ~ " ";
			}
			str = str[0..$-1];
		}
		else
		{
			str = to!(const(char)[])(val);
		}
		al_set_config_value(Payload, toStringz(section, buf1), toStringz(key, buf2), toStringz(str, buf3));
	}
}
