module game.RandomName;

import tango.math.random.Random;

char[] GenerateRandomName(Random random)
{
	char[] ret;
	while(true)
	{
		const(char)[] consonants = "BBBCCCCCCDDDDDDFFFFFGGGGHHJKLLLLLLMMMMMMMNNNNNNNPPPPQRRRRSSSSSSTTTTTTTTTVVXZWY";
		const(char)[] vowels = "AAAEEEEIIIOOOU";
		const(char)[][] clusters = ["CR", "CH", "ZH", "TH", "SS", "TT", "RR", "WR", "TR", "NDR", "NT"];
		
		char get_vowel()
		{
			return vowels[random.uniformR(vowels.length)];
		}
		
		char get_consonant()
		{
			return consonants[random.uniformR(consonants.length)];
		}
		
		const(char)[] get_cluster()
		{
			return clusters[random.uniformR(clusters.length)];
		}
		
		if(random.uniformR(2) == 0)
			ret ~= get_vowel;
		
		size_t num_syllables = random.uniformR2(2, 3);
		foreach(ii; 0..num_syllables)
		{
			if(random.uniformR(10) == 0)
				ret ~= get_cluster;
			else
				ret ~= get_consonant;
			ret ~= get_vowel;
			if(random.uniformR(4) == 0)
				ret ~= get_vowel;
		}
		
		if(random.uniformR(2) == 0)
			ret ~= get_consonant;
		
		if(ret.length > 8)
			ret.length = 0;
		else
			return ret;
	}
	assert(0);
}
