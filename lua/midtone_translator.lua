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

ym_pattern = "^.[" .. ym_keys .. "]"

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
	if not rime_type:match("[YM]") then
		medial = rime_type
	end

	py = onset .. medial .. final

	py = py:gsub("^g([iv])", "j%1")
	py = py:gsub("^k([iv])", "q%1")
	py = py:gsub("^h([iv])", "x%1")
	py = py:gsub("^z([iv])", "j%1")
	py = py:gsub("^c([iv])", "q%1")
	py = py:gsub("^s([iv])", "x%1")

	py = py:gsub("^([zcsr]h?)$", "%1i")
	py = py:gsub("([iuv])en", "%1n")
	py = py:gsub("^v", "iu")
	py = py:gsub("vng", "iung")
	py = py:gsub("^i$", "yi")
	py = py:gsub("^in", "yin")
	py = py:gsub("^u$", "wu")
	py = py:gsub("^i", "y")
	py = py:gsub("^u", "w")
	py = py:gsub("wn", "wen")
	py = py:gsub("([jqx])v", "%1u")
	py = py:gsub("ung", "ong")
	py = py:gsub("uei", "ui")
	py = py:gsub("iou", "iu")

	return py .. tone
end

local function code_to_pinyin(code, maps)
	if #code < 2 or #code > 3 then
		return {err = "code length not in [2, 3]"}
	end

	local rime_type = maps.key2type[code:sub(2,2)] or ""
	local tone = maps.key2tone[code:sub(2,2)] or "1"

	local onset = ""
	local final = ""

	if #code == 2 then
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

	local pinyin = ""
	for _, code in ipairs(codes) do
		py = code_to_pinyin(code, maps)
		if py.err then return end
		pinyin = pinyin .. py
	end

	local t = env.tran:query(pinyin,seg)
	if not t then return end
	for cand in t:iter() do
		cand.preedit = inp
		yield(cand)
	end
end

return M
