local config = require("midtone_config")

local ym_keys = ""
local i_keys = ""

local maps = {}
maps.key2onset = {}
maps.key2type = {}
maps.key2tone = {}
maps.key2final = {}
for i, key in ipairs(config.keyboard) do
	maps.key2onset[key] = config.onset_map[i]
	maps.key2type[key] = config.type_map[i]
	maps.key2tone[key] = config.tone_map[i]
	maps.key2final[key] = config.final_map[i]

	if config.type_map[i]:match("[YM]") then
		ym_keys = ym_keys .. key
	end
	if config.onset_map[i] == "I" then
		i_keys = i_keys .. key
	end
end

tonal_letters = {
	["a1"] = "ā",
	["a2"] = "á",
	["a3"] = "ǎ",
	["a4"] = "à",
	["e1"] = "ē",
	["e2"] = "é",
	["e3"] = "ě",
	["e4"] = "è",
	["o1"] = "ō",
	["o2"] = "ó",
	["o3"] = "ǒ",
	["o4"] = "ò",
	["i1"] = "ī",
	["i2"] = "í",
	["i3"] = "ǐ",
	["i4"] = "ì",
	["u1"] = "ū",
	["u2"] = "ú",
	["u3"] = "ǔ",
	["u4"] = "ù",
	["ü1"] = "ǖ",
	["ü2"] = "ǘ",
	["ü3"] = "ǚ",
	["ü4"] = "ǜ",
	["v1"] = "ǖ",
	["v2"] = "ǘ",
	["v3"] = "ǚ",
	["v4"] = "ǜ",
	["ê1"] = "ê̄",
	["ê2"] = "ế",
	["ê3"] = "ê̌",
	["ê4"] = "ề",
	["eh1"] = "ê̄",
	["eh2"] = "ế",
	["eh3"] = "ê̌",
	["eh4"] = "ề",
	["m1"] = "m̄",
	["m2"] = "ḿ",
	["m3"] = "m̌ ",
	["m4"] = "m̀",
	["n1"] = "n̄",
	["n2"] = "ń",
	["n3"] = "ň",
	["n4"] = "ǹ",
}

local py2zy = {
	["b"] = "ㄅ",
	["p"] = "ㄆ",
	["m"] = "ㄇ",
	["f"] = "ㄈ",
	["d"] = "ㄉ",
	["t"] = "ㄊ",
	["n"] = "ㄋ",
	["l"] = "ㄌ",
	["g"] = "ㄍ",
	["k"] = "ㄎ",
	["h"] = "ㄏ",
	["j"] = "ㄐ",
	["q"] = "ㄑ",
	["x"] = "ㄒ",
	["zh"] = "ㄓ",
	["ch"] = "ㄔ",
	["sh"] = "ㄕ",
	["r"] = "ㄖ",
	["z"] = "ㄗ",
	["c"] = "ㄘ",
	["s"] = "ㄙ",
	["i"] = "ㄧ",
	["u"] = "ㄨ",
	["v"] = "ㄩ",
	["a"] = "ㄚ",
	["o"] = "ㄛ",
	["e"] = "ㄜ",
	["eh"] = "ㄝ",
	["ai"] = "ㄞ",
	["ei"] = "ㄟ",
	["ao"] = "ㄠ",
	["ou"] = "ㄡ",
	["an"] = "ㄢ",
	["en"] = "ㄣ",
	["ang"] = "ㄤ",
	["eng"] = "ㄥ",
	["er"] = "ㄦ",
	["1"] = "ˉ",
	["2"] = "ˊ",
	["3"] = "ˇ",
	["4"] = "ˋ",
	["5"] = "˙",
}

local missing_sym = "~"

local function split_input(inp, ymkeys, ikeys)
	codes = {}

	for i=1,1000 do
		local mat = inp:match("^.["..ymkeys.."]")
		mat = mat or inp:match("^["..ikeys.."].")
		mat = mat or inp:match("^...")

		if not mat then
			codes.remainder = inp
			break
		end

		table.insert(codes, mat)

		if mat == inp then break end

		inp = inp:sub(#mat+1)
	end

	return codes
end

local function make_pinyin(onset, final, tone, rime_type)
	local medial = ""
	if not rime_type:match("^[YM]$") then
		medial = rime_type
	end

	if rime_type == "M" then
		if onset:match("^[bpmf]$") then
			final = "o"
		elseif onset:match("^[dtnlgkh]$") then
			final = "e"
		end
	end

	py = onset .. medial .. final

	py = py:gsub("g([iv])", "j%1")
           :gsub("k([iv])", "q%1")
           :gsub("h([iv])", "x%1")
           :gsub("z([iv])", "j%1")
           :gsub("c([iv])", "q%1")
           :gsub("s([iv])", "x%1")

	py = py:gsub("([iuv])eh$", "%1e")
	       :gsub("io$", "iou")
		   :gsub("iei$", "ie")
		   :gsub("ue$", "uei")
		   :gsub("uou$", "uo")
		   :gsub("vei$", "ve")

	py = py:gsub("^([zcsr]h?)$", "%1i")
           :gsub("([iuv])en", "%1n")
           :gsub("^v", "iu")
           :gsub("vng", "iung")
           :gsub("^i$", "yi")
           :gsub("^in", "yin")
           :gsub("^u$", "wu")
           :gsub("^i", "y")
           :gsub("^u", "w")
           :gsub("wn", "wen")
           :gsub("([jqx])v", "%1u")
           :gsub("ung", "ong")
           :gsub("uei", "ui")
           :gsub("iou", "iu")

	return py .. tone
end

local function code_to_pinyin(code, maps)
	if code == "" then return "" end

	if #code > 3 then
		return {err = "code length > 3"}
	end

	local rime_type = maps.key2type[code:sub(2,2)] or ""
	local tone = maps.key2tone[code:sub(2,2)] or ""

	local onset = ""
	local final = ""

	if #code == 1 then
		return maps.key2onset[code] or code
	elseif #code == 2 then
		if rime_type == "Y" then
			final = maps.key2final[code:sub(1,1)]
		else
			onset = maps.key2onset[code:sub(1,1)]
		end
		if onset == "I" then
			onset = ""
			final = ""
		end
	else
		onset = maps.key2onset[code:sub(1,1)]
		final = maps.key2final[code:sub(3,3)]
	end

	return make_pinyin(onset, final, tone, rime_type)
end

function terra_to_normal(py)
	py = py:gsub("5$", "")

	py = py:gsub("([aeiou])(ng?)([1234])", "%1%3%2")
	py = py:gsub("([aeiou])(r)([1234])", "%1%3%2")
	py = py:gsub("([aeo])([iuo])([1234])", "%1%3%2")
	py = py:gsub("ng([1234])", "n%1g")

	local core_tone = py:match(".h?%d")
	local tonal_letter = tonal_letters[core_tone]

	if tonal_letter then
		py = py:gsub(core_tone, tonal_letter)
	end

	py = py:gsub("v", "ü")
	py = py:gsub("eh", "ê")

	py = py:gsub("1", "ˉ")
	py = py:gsub("2", "ˊ")
	py = py:gsub("3", "ˇ")
	py = py:gsub("4", "ˋ")
	py = py:gsub("5", "˙")

	return py
end

function terra_to_zhuyin(py)
	py = py:gsub("^(5)(.+)$", "%2%1`")
	py = py:gsub("^(.+)5$", "5%1")
	py = py:gsub("`$", "")

	py = py:gsub("iu", "iou")
	       :gsub("ui", "uei")
	       :gsub("ong", "ung")
	       :gsub("yi?", "i")
	       :gsub("wu?", "u")
	       :gsub("iu", "v")
	       :gsub("([jgx])u", "%1v")
	       :gsub("([iuv])n", "%1en")
	       :gsub("zhi?", "ㄓ")
	       :gsub("chi?", "ㄔ")
	       :gsub("shi?", "ㄕ")
	       :gsub("ai", "ㄞ")
	       :gsub("ei", "ㄟ")
	       :gsub("ao", "ㄠ")
	       :gsub("ou", "ㄡ")
	       :gsub("ang", "ㄤ")
	       :gsub("eng", "ㄥ")
	       :gsub("an", "ㄢ")
	       :gsub("en", "ㄣ")
	       :gsub("er", "ㄦ")
	       :gsub("eh", "ㄝ")
	       :gsub("([iv])e", "%1ㄝ")

	for p, z in pairs(py2zy) do
		py = py:gsub(p,z)
	end

	return py
end

function gen_partial_pinyin(code, maps)
	if code == "" then return "" end

	if #code == 1 then
		return maps.key2onset[code] or missing_sym
	end

	local py = maps.key2tone[code:sub(2,2)] or ""
	py = py .. (maps.key2onset[code:sub(1,1)] or missing_sym)
	py = py .. (maps.key2type[code:sub(2,2)] or missing_sym)

	py = py:gsub("g([iv])", "j%1")
           :gsub("k([iv])", "q%1")
           :gsub("h([iv])", "x%1")
           :gsub("z([iv])", "j%1")
           :gsub("c([iv])", "q%1")
           :gsub("s([iv])", "x%1")

	return py
end

local M={}

function M.init(env)
	local midtone = Schema(env.engine.schema.schema_id or "")
	env.tran = Component.Translator(env.engine, midtone, "translator", "script_translator")
end

function M.fini(env)
	env.tran:disconnect()
end

function M.func(inp, seg, env)
	local codes = split_input(inp, ym_keys, i_keys)

	local terra_to_yibao = terra_to_normal
	if env.engine.context:get_option("display_zhuyin") then
		terra_to_yibao = terra_to_zhuyin
	end

	local pinyin = ""
	local yibiao = ""
	for _, code in ipairs(codes) do
		py = code_to_pinyin(code, maps)
		if py.err then return end
		pinyin = pinyin .. " " .. py
		yibiao = yibiao .. " " .. terra_to_yibao(py)
	end

	if codes.remainder then
		local ppy = gen_partial_pinyin(codes.remainder, maps)
		yibiao = yibiao .. " " .. terra_to_yibao(ppy)
		pinyin = pinyin .. " " .. ppy:gsub("%d", "")
	end

	yibiao = yibiao:gsub("^ ", "")
	pinyin = pinyin:gsub("^ ", "")

	local t = env.tran:query(pinyin,seg)


	local yb_cand = Candidate("yibiao", seg.start, seg._end, yibiao, " ")
	local cand_cnt = 0

	if not t then
		yield(yb_cand)
		return
	end

	for cand in t:iter() do
		cand_cnt = cand_cnt + 1
		if cand_cnt == 1 then
			cand.comment = yibiao
		end
		cand.preedit = ""
		yield(cand)
	end
end

return M
