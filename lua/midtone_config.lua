local config = {}

config.keyboard = {
	"q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
	"a", "s", "d", "f", "g", "h", "j", "k", "l", ";",
	"z", "x", "c", "v", "b", "n", "m", ",", ".", "/"
}

config.onset_map = {
	"p", "c", "t",  "k", nil, nil, "ch", "r", nil, nil,
	"b", "z", "d",  "g", "", "h",  "zh", "n", "l", nil,
	"f", "s", "sh", "I", nil, nil, "m"
}

config.type_map = {
	"Y","Y","Y","Y","Y","M","M","M","M","M",
	"i","i","i","i","i","","","","","",
	"v","v","v","v","v","u","u","u","u","u"
}

config.tone_map = {
	"1", "2", "3", "4", "5", "5", "4", "3", "2", "1",
	"1", "2", "3", "4", "5", "5", "4", "3", "2", "1",
	"1", "2", "3", "4", "5", "5", "4", "3", "2", "1"
}

config.final_map = {
	"n","ng","er","m",nil,nil,"ai","eh","o",nil,
	"en","eng","ang","an",nil,"e","a","ei","ou","",
	nil,nil,nil,nil,nil,nil,"ao",nil,nil,nil
}

return config
