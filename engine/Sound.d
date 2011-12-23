module engine.Sound;

import engine.Holder;
import engine.MathTypes;

import allegro5.allegro;
import allegro5.allegro_audio;

import tango.util.MinMax;

const MaxInstances = 5;
const CenterSize = 250.0f;

class CSound : CHolder!(ALLEGRO_SAMPLE*, al_destroy_sample)
{
	this(ALLEGRO_SAMPLE* spl)
	{
		super(spl);
		
		foreach(ref inst; Instances)
		{
			auto spl_inst = al_create_sample_instance(spl);
			al_attach_sample_instance_to_mixer(spl_inst, al_get_default_mixer());
			
			inst = new CSampleInstance(spl_inst);
		}
	}
	
	override
	void Dispose()
	{
		foreach(inst; Instances)
			inst.Dispose();
		super.Dispose();
	}
	
	CSampleInstance Play(SVector2D pos, bool loop = false)
	{
		CSampleInstance ret;
		foreach(inst; Instances)
		{
			if(!inst.Playing && !inst.Busy)
			{
				inst.Playing = true;
				inst.Loop = loop;
				inst.Position = pos;
				
				ret = inst;
				break;
			}
		}
		return ret;
	}
	
	void Update(float dt, SVector2D center)
	{
		foreach(inst; Instances)
			inst.Update(dt, center);
	}
protected:
	CSampleInstance[MaxInstances] Instances;
}

class CSampleInstance : CHolder!(ALLEGRO_SAMPLE_INSTANCE*, al_destroy_sample_instance)
{
	this(ALLEGRO_SAMPLE_INSTANCE* inst)
	{
		super(inst);
	}
	
	bool Playing()
	{
		return al_get_sample_instance_playing(Get);
	}
	
	void Playing(bool playing)
	{
		al_set_sample_instance_playing(Get, playing);
	}
	
	void Loop(bool loop)
	{
		al_set_sample_instance_playmode(Get, loop ? ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP : ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE);
	}
	
	void Update(float dt, SVector2D center)
	{
		if(!Playing)
			return;

		auto dir = Position - center;
		auto pan = dir.X;
		
		if(pan > CenterSize)
		{
			pan = (pan - CenterSize) / CenterSize;
			pan = min(pan, 1.0f);
		}
		else if(pan < -CenterSize)
		{
			pan = (pan + CenterSize) / CenterSize;
			pan = max(pan, -1.0f);
		}
		else
		{
			pan = 0;
		}
		
		auto gain = dir.Length;
		if(gain > CenterSize)
			gain = max(CenterSize / gain, 1.0f);
		else
			gain = 1;
		
		al_set_sample_instance_pan(Get, pan);
		al_set_sample_instance_gain(Get, gain);
	}
	
	bool Busy = false;
	SVector2D Position;
}
