
-- Recognizes offensive language in text
if (CLIENT) then
	CreateClientConVar("echoes_profanity", "0")

	cvars.AddChangeCallback("echoes_profanity", function(name, old, new)
		if (new == "0") then return end

		for i = 1, #echoes do
			local echo = echoes[i]
			if (!echo.explicit) then continue end

			echo.init = 0
		end
	end, "echoes_profanity")
end

-- Common letter substitutions
local substitutions = {
	a = "[aA@4αΑа]",			-- Latin a, @, 4, Greek alpha (lower & upper), Cyrillic a
	b = "[bB8βВв]",			-- Latin b, 8, Greek beta, Cyrillic Ve (both cases)
	c = "[cCçćčс]",			-- Latin c, cedilla/accents, Cyrillic es
	d = "[dDđ]",				-- Latin d, with đ (a common variant)
	e = "[eE3€εєе]",			-- Latin e, 3, euro sign, Greek epsilon, Ukrainian IE, Cyrillic е
	f = "[fFƒ4]",				-- Latin f, plus the function symbol ƒ
	g = "[gG69]",				-- Latin g, 6, 9 (often used)
	h = "[hH]",				-- Latin h (no common homoglyphs added)
	i = "[iI1!|íìîïιі]",		-- Latin i, 1, exclamation, vertical bar, accented forms, Greek iota, Ukrainian i
	j = "[jJ]",				-- Latin j (rarely substituted)
	k = "[kKκк]",				-- Latin k, Greek kappa, Cyrillic ka
	l = "[lL1|ł]",			-- Latin l, 1, vertical bar, Polish ł
	m = "[mM]",				-- Latin m (no common homoglyphs added)
	n = "[nNñÑн]",			-- Latin n, ñ (both cases), Cyrillic en
	o = "[oO0öóòôοОо]",		-- Latin o, 0, umlauted/accents, Greek omicron, Cyrillic O/o
	p = "[pPρр]",				-- Latin p, Greek rho, Cyrillic er
	q = "[qQ9]",				-- Latin q (and sometimes 9 is substituted)
	r = "[rR]",				-- Latin r (not many typical substitutions)
	s = "[sS$5šśѕ]",			-- Latin s, $, 5, accented s variants, Cyrillic es (ѕ)
	t = "[tT7+τт]",			-- Latin t, 7, +, Greek tau, Cyrillic te
	u = "[uUυυу]",			-- Latin u, Greek upsilon, Cyrillic u (note: some upsilon variants may repeat)
	v = "[vVνв]",				-- Latin v, Greek nu (ν), Cyrillic ve
	w = "[wWω]",				-- Latin w, Greek omega (as a rough visual substitute)
	x = "[xXχх]",				-- Latin x, Greek chi, Cyrillic ha
	y = "[yY¥]",				-- Latin y, yen symbol (a common substitution)
	z = "[zZ2žźз]"			-- Latin z, 2, accented z's, Cyrillic ze
}

-- Helper function to remove repeated characters from a string
local function RemoveRepeatedChars(text)
	local result = ""
	local prev = ""

	for i = 1, #text do
		local char = text:sub(i, i)
		if (char == prev) then continue end

		result = result .. char
		prev = char
	end

	return result
end

local maxGap = 1 -- Gotta figure out a better way to do this...

-- Check if the pattern exists in the given string
local function FuzzyMatch(text, target)
	text = RemoveRepeatedChars(text)

	local pos = 1

	for i = 1, #target do
		local char = target:sub(i, i)
		local lower_char = char:lower()
		local pattern = substitutions[lower_char] or char

		-- Find the next occurrence of the current letter's pattern
		local s, e = string.find(text, pattern, pos)

		if (!s) then
			return false  -- Current letter not found
		end

		if (i > 1) then
			local gapLength = s - pos  -- Gap between previous match end and current match start

			if (gapLength > maxGap) then
				return false  -- Gap is too large, abort
			end
		end

		pos = e + 1  -- Advance past the current match
	end

	return true  -- All characters matched with acceptable gaps
end

-- Bleach your eyes
local wordList = {
	"kil yourself",
	"retard",
	"fagot",
	"fagot",
	"trany",
	"negro",
	"niger",
	"chink",
	"honky",
	"tranies",
	"sisy",
	"spic",
	"niga",
	"paki",
	"gook",
	"kike",
	"dyke",
	"fgt",
	"fag",
	"kys"
}

function IsOffensive(text)
	for _, target in ipairs(wordList) do
		local found = FuzzyMatch(text, target)
		if (!found) then continue end

		return true
	end

	return false
end
