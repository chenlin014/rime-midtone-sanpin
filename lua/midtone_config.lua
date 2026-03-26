local config = {}

config.keyboard = {
	"q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
	"a", "s", "d", "f", "g", "h", "j", "k", "l", ";",
	"z", "x", "c", "v", "b", "n", "m", ",", ".", "/"
}

config.onset_map = {
	"r",  "ch", "k", "t", nil, nil, "p", "c", "s", nil,
	"sh", "zh", "g", "d", "f", "h", "b", "z", "l", nil,
	nil,  "I",  "",  "n", nil, nil, "m"
}

config.medial_map = {
	"Y","Y","Y","Y","Y","u","u","u","u","u",
	"i","i","i","i","i","","","","","",
	"v","v","v","v","v","M","M","M","M","M"
}

config.tone_map = {
	1, 2, 3, 4, 5, 5, 4, 3, 2, 1,
	1, 2, 3, 4, 5, 5, 4, 3, 2, 1,
	1, 2, 3, 4, 5, 5, 4, 3, 2, 1
}

config.final_map = {
	"n","ng","er","m",nil,nil,"ai","eh","o",nil,
	"en","eng","ang","an",nil,"e","a","ei","ou","",
	nil,nil,nil,nil,nil,nil,"ao",nil,nil,nil
}

return config
