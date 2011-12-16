module engine.Config;

import engine.Holder;

import allegro5.allegro;

import tango.stdc.stringz;
import tango.core.Exception;
import tango.util.Convert;

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
		auto section_ptr = al_get_config_value(Payload, toStringz(section, buf1), toStringz(key, buf2));
		
		if(section_ptr is null)
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
		
		return to!(T)(fromStringz(section_ptr));
	}
	
	void Set(T)(const(char)[] section, const(char)[] key, T val)
	{
		char[256] buf1, buf2, buf3;
		auto str = to!(const(char)[])(val);
		al_set_config_value(Payload, toStringz(section, buf1), toStringz(key, buf2), toStringz(str, buf3));
	}
}
