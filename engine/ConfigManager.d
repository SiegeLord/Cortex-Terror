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
