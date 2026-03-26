local M={}

local function M.init(env)
	env.tran = Component.ScriptTranslator(env.engine, env.name_space, "script_translator")
end

function M.fini(env)
end

function M.func(inp, seg, env)
	--local t = env.tran:query(inp,seg)
	--if not t then return end
	for cand in t:iter() do
		yield(Candidate(inp, seg.start, seg._end, "aaa", " "))
	end
end

return M
