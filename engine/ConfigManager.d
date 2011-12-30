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

module engine.ConfigManager;

import engine.ResourceManager;
import engine.Config;

class CConfigManager : CResourceManager!(CConfig)
{
	this(CConfigManager parent = null)
	{
		super(parent);
		DefaultVal = new CConfig;
	}
	
	CConfig Load(const(char)[] filename)
	{
		auto ret = LoadExisting(filename);
		if(ret is null)
		{
			return Insert(filename, new CConfig(filename));
		}
		else
		{
			return ret;
		}
	}
	
	CConfig Default()
	{
		return DefaultVal;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		DefaultVal.Dispose;
	}
	
protected:
	CConfig DefaultVal;

	override
	void Destroy(CConfig cfg)
	{
		cfg.Dispose();
	}
}
