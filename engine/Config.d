/*
This file is part of Cortex Terror, a game of galactic exploration and domination.
Copyright (C) 2011 Pavel Sountsov

Cortex Terror is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cortex Terror is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cortex Terror. If not, see <http:#www.gnu.org/licenses/>.
*/

module engine.Config;

import engine.Holder;
import engine.Util;

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
		
		Filename = filename;
		
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
		
		const(char)[] str = fromStringz(value_ptr);
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
	
	void Save(const(char)[] filename = null)
	{
		char[256] buf1;
		
		if(filename !is null)
		{
			Filename = filename;
		}
		else if(Filename.length == 0)
		{
			throw new Exception("Can't save to an empty filename");
		}
		
		al_save_config_file(toStringz(Filename, buf1), Payload);
	}
	
	const(char)[] Filename;
}
