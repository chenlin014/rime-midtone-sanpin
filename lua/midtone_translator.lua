local config = require("midtone_config")

local maps = {}
maps.key2onset = {}
maps.key2medial = {}
maps.key2tone = {}
maps.key2final = {}
for i, key in ipairs(config.keyboard) do
	maps.key2onset[key] = config.onset_map[i]
	maps.key2medial[key] = config.medial_map[i]
	maps.key2tone[key] = config.tone_map[i]
	maps.key2final[key] = config.final_map[i]
end

local M={}

function M.init(env)
	env.tran = Component.Translator(env.engine, Schema("midtone_dev"), "translator", "script_translator")
end

function M.fini(env)
	env.tran:disconnect()
end

function M.func(inp, seg, env)
	if #inp ~= 3 then return end

	local pinyin = maps.key2onset[inp:sub(1,1)]
	pinyin = pinyin .. maps.key2medial[inp:sub(2,2)]
	pinyin = pinyin .. maps.key2final[inp:sub(3,3)]
	pinyin = pinyin .. tostring(maps.key2tone[inp:sub(2,2)])

	local t = env.tran:query(pinyin,seg)
	if not t then return end
	for cand in t:iter() do
		yield(cand)
	end
end

return M
