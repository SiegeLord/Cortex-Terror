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

module game.Music;

import game.IGameMode;

import engine.Disposable;

import allegro5.allegro_audio;

import tango.io.Stdout;

enum EMusic
{
	Peace,
	Medium,
	War,
	None
}

class CMusic : CDisposable
{
	this(bool no_music)
	{
		NoMusic = no_music;
	}
	
	void Play(EMusic music)
	{
		if(NoMusic)
			return;
		
		if(CurMusic == music)
			return;
		
		CurMusic = music;
		Stop;
		
		final switch(music)
		{
			case EMusic.Peace:
				Stream = al_load_audio_stream("data/music/peace.xm", 4, 2048);
				break;
			case EMusic.Medium:
				Stream = al_load_audio_stream("data/music/medium.xm", 4, 2048);
				break;
			case EMusic.War:
				Stream = al_load_audio_stream("data/music/war.xm", 4, 2048);
				break;
			case EMusic.None:
				Stop;
				break;
		}
		
		if(Stream !is null)
		{
			al_attach_audio_stream_to_mixer(Stream, al_get_default_mixer());
			al_set_audio_stream_playmode(Stream, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP);
		}
	}
	
	void Stop()
	{
		if(Stream !is null)
		{
			al_set_audio_stream_playing(Stream, false);
			al_destroy_audio_stream(Stream);
			Stream = null;
		}
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		Stop;
	}
protected:
	EMusic CurMusic = EMusic.None;
	bool NoMusic = false;
	ALLEGRO_AUDIO_STREAM* Stream;
}
