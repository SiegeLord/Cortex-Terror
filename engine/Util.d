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
