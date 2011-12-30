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

module engine.Util;

const(char)[] Prop(const(char)[] type, const(char)[] name, const(char)[] get_attr = "", const(char)[] set_attr = "")()
{
	return
	get_attr ~ "
	" ~ type ~ " " ~ name ~ "()
	{
		return " ~ name ~ "Val;
	}
	
	" ~ set_attr ~ "
	" ~ type ~ " " ~ name ~ "(" ~ type ~ " val)
	{
		return " ~ name ~ "Val = val;
	}";
}

