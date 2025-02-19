
-- Recognizes offensive language in text

-- Common letter substitutions
local substitutions = {
  a = "[aA@4αΑа]",			-- Latin a, @, 4, Greek alpha (lower & upper), Cyrillic a
  b = "[bB8βВв]",			-- Latin b, 8, Greek beta, Cyrillic Ve (both cases)
  c = "[cCçćčс]",			-- Latin c, cedilla/accents, Cyrillic es
  d = "[dDđ]",				-- Latin d, with đ (a common variant)
  e = "[eE3€εєе]",			-- Latin e, 3, euro sign, Greek epsilon, Ukrainian IE, Cyrillic е
  f = "[fFƒ]",				-- Latin f, plus the function symbol ƒ
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

-- Builds a pattern from a target word
local function CreateFuzzyPattern(target)
	local pattern = ""

	for i = 1, #target do
		local c = target:sub(i, i)
		local lower_c = c:lower()
		local sub = substitutions[lower_c] or c-- use substitution if available

		pattern = pattern .. sub

		if (i < #target) then
			pattern = pattern .. ".-"-- allow for any characters in-between
		end
	end

	return pattern
end

-- Check if the pattern exists in the given string
local function FuzzyMatch(text, target)
	local pattern = CreateFuzzyPattern(target)
	local start, finish = string.find(text, pattern)

	return start, finish, pattern
end

-- Bleach your eyes
local wordList = {
	"kill yourself",
	"redskin",
	"faggot",
	"nigger",
	"retard",
	"chink",
	"honky",
	"sissy",
	"spic",
	"paki",
	"gook",
	"kike",
	"dyke",
	"fgt",
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
