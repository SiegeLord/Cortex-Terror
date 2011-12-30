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

/*
Copyright (c) 2010-2011 Pavel Sountsov

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
*/

module engine.Disposable;

version(DebugDisposable) import tango.stdc.stdio;

/**
 * A simple class that formalizes the non-managed resource management. The advantage of using this
 * is that with version DebugDisposable defined, it will track whether all the resources were disposed of
 */
class CDisposable
{
	this()
	{
		version(DebugDisposable)
		{
			InstanceCounts[this.classinfo.name]++;
		}
		
		IsDisposed = false;
	}
	
	void Dispose()
	{
		version(DebugDisposable)
		{
			if(!IsDisposed)
			{
				InstanceCounts[this.classinfo.name]--;
			}
		}

		IsDisposed = true;
	}
	
protected:
	bool IsDisposed = false;
}

version(DebugDisposable)
{
	size_t[char[]] InstanceCounts;

	static ~this()
	{
		printf("Disposable classes instance counts:\n");
		bool any = false;
		foreach(name, num; InstanceCounts)
		{
			if(num)
			{
				printf("%s: \033[1;31m%d\033[0m\n", (name ~ "\0").ptr, num);
				any = true;
			}
		}
		if(!any)
			printf("No leaked instances!\n");
	}
}
