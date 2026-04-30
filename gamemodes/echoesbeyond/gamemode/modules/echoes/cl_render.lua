
local __vtab = FindMetaTable("Vector")
local __vunpack = __vtab.Unpack
local __vset = __vtab.Set
local __vadd = __vtab.Add
local __vmul = __vtab.Mul
local __vsetunpacked = __vtab.SetUnpacked

local __mtab = FindMetaTable("VMatrix")
local __msetunpacked = __mtab.SetUnpacked

local echo_mtx = Matrix()
local __cos = math.cos
local __sin = math.sin

CreateClientConVar("echoes_showread", "1")
CreateClientConVar("echoes_renderdist", "25000000")
CreateClientConVar("echoes_disablereadsys", "0")
CreateClientConVar("echoes_disablesigning", "0")
CreateClientConVar("echoes_gabenmode", "0")
CreateClientConVar("echoes_distactivate", "0")

cvars.AddChangeCallback("echoes_disablesigning", function(name, old, new)
	for i = 1, #echoes do
		echoes[i].cachedText = nil
	end
end, "echoes_disablesigning")

local gabenNodeSounds = {
	"/gaben/al_intro",
	"/gaben/hl2_intro",
	"/gaben/l4d2_intro",
	"/gaben/l4d_intro",
	"/gaben/lc_intro",
	"/gaben/p2_intro"
}

local gabenIntroSounds = {
	"/gaben/al_node",
	"/gaben/ep1_node",
	"/gaben/ep2_node",
	"/gaben/hl2_node",
	"/gaben/l4d2_node",
	"/gaben/l4d_node",
	"/gaben/lc_node",
	"/gaben/p1_node",
	"/gaben/p2_node",
	"/gaben/tf2_node"
}

cvars.AddChangeCallback("echoes_gabenmode", function(name, old, new)
	if (new == "0") then return end

	EchoSound(table.Random(gabenNodeSounds), nil, 0.75)
end, "echoes_gabenmode")

local echoMat = Material("echoesbeyond/echo.png", "mips")
local echoBlankMat = Material("echoesbeyond/echo_blank.png", "mips")
local echoDotsMat = Material("echoesbeyond/echo_dots.png", "mips")
local echoDotSingleMat = Material("echoesbeyond/echo_dot_single.png", "mips")
local echoTranslateMat = Material("echoesbeyond/echo_translate.png", "mips")
local lightRenderDist = 3000000 -- How far the dynamic light should render
local activationDist = 6500 -- How close the player should be to activate the echo
local echoFadeDist = 2500 -- How far the echo should start fading
local echoToGroundFrac = 0

local function GetEchoPosition(echo)
	local x, y, z = __vunpack(echo.pos)

	return x, y, z - (echo.airHeight or 0) * echoToGroundFrac
end

local function ComputeSqrEchoDist(origin)
	local v = Vector()

	for i = 1, #echoes do
		local echo = echoes[i]
		local x, y, z = GetEchoPosition(echo)

		__vsetunpacked(v,x, y, z)
		echo.distSqr = origin:DistToSqr(v)
	end
end

local function UpdateEchoTextCache(inEchoes)
	local disableSigning = GetConVar("echoes_disablesigning"):GetBool()

	for _, echo in ipairs(inEchoes) do
		if (echo.cachedText) then continue end -- Already cached

		-- Cache wrapped text to avoid recalculations
		local text = echo.text

		if (disableSigning) then text = RemoveSigning(text) end

		local words = string.Explode(" ", text)
		local lines = {}
		local line = ""

		for j = 1, #words do
			local word = words[j]

			if (surface.GetTextSize(line .. " " .. word) > 512) then
				table.insert(lines, line)

				line = word
			else
				line = (line == "" and word or line .. " " .. word)
			end
		end

		table.insert(lines, line)

		for j = 1, math.floor(#lines / 2) do
			lines[j], lines[#lines - j + 1] = lines[#lines - j + 1], lines[j]
		end

		echo.cachedText = lines
	end
end

local cameraData = {
	cx = 0, cy = 0, cz = 0,
	fx = 0, fy = 0, fz = 0
}

local function EchoDistSortFunc(a,b) return a.distSqr > b.distSqr end
local function GetSortedVisibleEchoes()
	local renderVoidEchoes = GetConVar("echoes_enablevoidechoes"):GetBool()
	local cutOffDist = GetConVar("echoes_renderdist"):GetInt()
	local sortedEchoes = {}
	local cdata = cameraData
	local cx, cy, cz = cdata.cx, cdata.cy, cdata.cz
	local fx, fy, fz = cdata.fx, cdata.fy, cdata.fz

	for _, echo in ipairs(echoes) do
		if (echo.distSqr > cutOffDist) then continue end
		if (echo.inVoid and !renderVoidEchoes) then continue end

		local x, y, z = GetEchoPosition(echo)
		local dot = ((cx-x) * fx + (cy-y) * fy + (cz-z) * fz)

		if (dot > 0) then continue end -- Don't bother with anything behind the camera

		sortedEchoes[#sortedEchoes + 1] = echo
	end

	table.sort(sortedEchoes, EchoDistSortFunc)

	return sortedEchoes
end

local function UpdateEchoRotations(inEchoes, dt)
	local lerpFactor = math.Clamp(dt * 5, 0, 1)
	local cdata = cameraData
	local cx, cy, _ = cdata.cx, cdata.cy, cdata.cz

	for _, echo in ipairs(inEchoes) do
		local px, py, _ = GetEchoPosition(echo)
		local a = math.atan2(px - cx, py - cy)
		local b = echo._angle or 0
		local d = ((a - b) + math.pi) % (math.pi * 2) - math.pi
		local t = b + (d < math.pi and d or d - (math.pi * 2))

		echo._angle = b * (1-lerpFactor) + t * lerpFactor
	end
end

local function UpdateEchoInteractions(inEchoes, curTimeSpeed, dt)
	local disableReadSys = GetConVar("echoes_disablereadsys"):GetBool()
	local breathLayer = math.sin(curTimeSpeed) * 0.5
	local activeZOffset = 24 + breathLayer
	local readZOffset = 20
	local gabenMode = GetConVar("echoes_gabenmode"):GetBool()
	local profanity = GetConVar("echoes_profanity"):GetBool()
	local distActivate = GetConVar("echoes_distactivate"):GetBool()
	local threshold

	if (!distActivate) then
		local fov = GetConVar("fov_desired"):GetFloat()
		threshold = math.cos(math.rad(fov / 2 - 10)) -- 10 degree buffer
	end

	for _, echo in ipairs(inEchoes) do
		echo.z_offset = echo.z_offset or 0
		local read = echo.read and !disableReadSys
		local bOwner = echo.isOwner

		if (((echo.explicit and profanity) or !echo.explicit) and !echo.loading) then
			local inView = true

			-- Determine if the player is looking at the echo independently of vertical angle
			if (!distActivate) then
				local x, y, _ = GetEchoPosition(echo)
				local cdata = cameraData
				local dx, dy = x - cdata.cx, y - cdata.cy
				local dist2d = math.sqrt(dx * dx + dy * dy)
				local fdist2d = math.sqrt(cdata.fx * cdata.fx + cdata.fy * cdata.fy)

				if (dist2d > 0 and fdist2d > 0) then
					local dot = (dx * cdata.fx + dy * cdata.fy) / (dist2d * fdist2d)

					inView = dot >= threshold
				end
			end

			if (echo.distSqr < activationDist and inView) then
				local active = math.min(echo.active + dt * 3, 1)
				local heightDiff = EyePos().z - echo.pos.z - 32

				echo.active = active
				echo.z_offset = Lerp(dt * 3, echo.z_offset, activeZOffset + heightDiff)

				if (!echo.soundActive) then
					echo.soundActive = true

					if (gabenMode) then
						EchoSound(table.Random(gabenIntroSounds), nil, 0.75)
					else
						EchoSound("echo_activate", echo.special and math.random(115, 125) or echo.explicit and math.random(65, 75) or (echo.originalText != nil) and math.random(105, 115) or math.random(95, 105))
					end
				end

				if (active == 1 and !bOwner and !echo.read and !echo.special) then
					local savedData = file.ReadOrCreate("echoesbeyond/readechoes.txt")
					savedData[#savedData + 1] = echo.id

					echo.read = true

					readEchoCount = readEchoCount + 1

					file.CreateDir("echoesbeyond")
					file.Write("echoesbeyond/readechoes.txt", util.TableToJSON(savedData))
				end
			else
				echo.active = math.max(echo.active - dt * 0.5, 0)
				echo.z_offset = Lerp(dt * 1.5, echo.z_offset, read and -readZOffset or 0)

				if (echo.soundActive) then
					echo.soundActive = false
				end
			end
		end
	end
end

local function ComputeEchoMtx(mtx, pos, rot, size, z_offset)
	local px, py, pz = __vunpack(pos)
	local c,s = __cos(rot), __sin(rot)

	__msetunpacked(mtx,
	c * size, 0 * size, s * size, px,
	-s * size, 0 * size, c * size, py,
	0 * size, -1 * size, 0 * size, pz + (z_offset or 0),
	0,0,0,1)
end

local TRANSLATE_BASE_URL = "https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=auto&tl="

-- Maps Steam/GMod cl_language values to ISO 639-1 codes
local steamLangToISO = {
	english    = "en",
	russian    = "ru",
	german     = "de",
	french     = "fr",
	spanish    = "es",
	latam      = "es",
	portuguese = "pt",
	brazilian  = "pt",
	italian    = "it",
	dutch      = "nl",
	polish     = "pl",
	czech      = "cs",
	hungarian  = "hu",
	roumanian  = "ro",
	turkish    = "tr",
	greek      = "el",
	swedish    = "sv",
	norwegian  = "no",
	danish     = "da",
	finnish    = "fi",
	japanese   = "ja",
	korean     = "ko",
	koreana    = "ko",
	schinese   = "zh-CN",
	tchinese   = "zh-TW",
	thai       = "th",
	bulgarian  = "bg",
	ukrainian  = "uk",
	vietnamese = "vi",
	arabic     = "ar",
}

local function GetTranslateTargetLang()
	local steamLang = GetConVar("cl_language"):GetString():lower()

	return steamLangToISO[steamLang] or "en"
end

local function UrlEncode(str)
	return str:gsub("[^%w%-%.%_%~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

-- Offline language detection: Unicode script blocks + distinctive Latin diacritics
-- Returns an ISO 639-1 code if the language is detectable, or nil for plain ASCII / ambiguous text.
-- Uses raw UTF-8 byte arithmetic to avoid requiring the bit library.
-- I hate this with every fiber of my being and if it breaks I will kill myself
local function DetectTextScript(text)
	local i = 1
	local n = #text

	while i <= n do
		local b1 = text:byte(i)

		if (b1 < 0x80) then
			i = i + 1
		elseif (b1 >= 0xC2 and b1 <= 0xDF) then -- 2-byte UTF-8 sequence (U+0080 – U+07FF)
			local b2 = text:byte(i + 1) or 0x80

			if (b2 >= 0x80 and b2 <= 0xBF) then
				local cp = (b1 - 0xC0) * 64 + (b2 - 0x80)

				if (cp >= 0x0400 and cp <= 0x04FF) then return "ru" -- Cyrillic
				elseif (cp >= 0x0370 and cp <= 0x03FF) then return "el" -- Greek
				elseif (cp >= 0x0600 and cp <= 0x06FF) then return "ar" -- Arabic
				elseif (cp == 0x00DF or cp == 0x00E4 or cp == 0x00F6 or
				       cp == 0x00FC or cp == 0x00C4 or cp == 0x00D6 or
				       cp == 0x00DC) then return "de" -- ß ä ö ü (German)
				elseif (cp == 0x00F1 or cp == 0x00D1) then return "es" -- ñ (Spanish)
				elseif (cp == 0x00E3 or cp == 0x00F5 or
				       cp == 0x00C3 or cp == 0x00D5) then return "pt" -- ã õ (Portuguese)
				elseif (cp == 0x0105 or cp == 0x0119 or cp == 0x0142 or
				       cp == 0x0107 or cp == 0x0106 or cp == 0x0144 or
				       cp == 0x015B or cp == 0x015A or cp == 0x017A or
				       cp == 0x017C or cp == 0x017B) then return "pl" -- ą ę ł ć ś ź ż (Polish)
				elseif (cp == 0x0151 or cp == 0x0150 or
				       cp == 0x0171 or cp == 0x0170) then return "hu" -- ő ű (Hungarian)
				elseif (cp == 0x015F or cp == 0x015E or
				       cp == 0x011F or cp == 0x011E or
				       cp == 0x0131 or cp == 0x0130) then return "tr" -- ş ğ ı (Turkish)
				elseif (cp == 0x00E7 or cp == 0x00C7 or
				       cp == 0x0153 or cp == 0x0152) then return "fr" -- ç œ (French)
				end
			end

			i = i + 2
		elseif (b1 >= 0xE0 and b1 <= 0xEF) then -- 3-byte UTF-8 sequence (U+0800 – U+FFFF)
			local b2 = text:byte(i + 1) or 0x80
			local b3 = text:byte(i + 2) or 0x80

			if (b2 >= 0x80 and b2 <= 0xBF and b3 >= 0x80 and b3 <= 0xBF) then
				local cp = (b1 - 0xE0) * 4096 + (b2 - 0x80) * 64 + (b3 - 0x80)

				if (cp >= 0x3040 and cp <= 0x309F) then return "ja" -- Hiragana
				elseif (cp >= 0x30A0 and cp <= 0x30FF) then return "ja" -- Katakana
				elseif (cp >= 0x4E00 and cp <= 0x9FFF) then return "zh-CN" -- CJK Ideographs
				elseif (cp >= 0xAC00 and cp <= 0xD7FF) then return "ko" -- Hangul
				elseif (cp >= 0x0E00 and cp <= 0x0E7F) then return "th" -- Thai
				end
			end

			i = i + 3
		elseif (b1 >= 0xF0) then
			i = i + 4
		else
			i = i + 1
		end
	end

	return nil
end

local function UntranslateEcho(echo)
	echo.text = echo.originalText
	echo._detectedLang = nil  -- force re-detection from the restored original text
	echo.originalText = nil
	echo.translateDuration = nil
	echo.cachedText = nil
	echo.loading = false

	EchoSound("echo_translate", 75, 0.5)
end

function TranslateEcho(echo)
	if (echo.isTranslating) then return end

	if (echo.originalText) then
		local delay = echo.translateDuration or 0

		if (delay > 0) then
			echo.isTranslating = true
			echo.active = 0
			echo.loading = true

			EchoSound("echo_translate", 100)

			timer.Simple(delay, function()
				echo.isTranslating = false
				UntranslateEcho(echo)
			end)
		else
			UntranslateEcho(echo)
		end

		return
	end

	echo.isTranslating = true
	echo.originalText = echo.text
	echo.cachedText = nil
	echo.active = 0
	echo.loading = true
	echo._translateStart = SysTime()

	EchoSound("echo_translate", 75, 0.5)

	HTTP({
		method = "GET",
		url = TRANSLATE_BASE_URL .. GetTranslateTargetLang() .. "&q=" .. UrlEncode(echo.originalText),
		success = function(code, body)
			echo.isTranslating = false
			echo.loading = false
			echo.cachedText = nil
			echo.translateDuration = echo._translateStart and (SysTime() - echo._translateStart) or 0
			echo._translateStart = nil

			if (code == 200) then
				local ok, data = pcall(util.JSONToTable, body)

				-- Response: [[[translated, original, ...], ...], ..., src_lang]
				-- Collect all sentence segments from data[1]
				if (ok and data and data[1]) then
					local parts = {}

					for i = 1, #data[1] do
						local seg = data[1][i]

						if (seg and seg[1]) then
							parts[#parts + 1] = seg[1]
						end
					end

					if (#parts > 0) then
						echo.text = table.concat(parts, "")
						echo._detectedLang = nil  -- text changed; will re-detect if later untranslated

						EchoSound("echo_translate", 100)
					else
						EchoNotify("Translation failed. (Invalid response)")
						EchoSound("echo_translate", 50)
						echo.originalText = nil
					end
				else
					EchoNotify("Translation failed. (Invalid response)")
					EchoSound("echo_translate", 50)
					echo.originalText = nil
				end
			else
				EchoNotify("Translation failed. (HTTP " .. tostring(code) .. ")")
				EchoSound("echo_translate", 50)
				echo.originalText = nil
			end
		end,

		failed = function(err)
			echo.isTranslating = false
			echo.loading = false
			echo.cachedText = nil
			echo.originalText = nil
			echo._translateStart = nil

			EchoNotify("Translation failed. (" .. tostring(err) .. ")")
			EchoSound("echo_translate", 50)
		end,
	})
end

local lastPartyModeTime = 0

hook.Add("PreDrawEffects", "echoes_render_PreDrawEffects", function(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	local org, ang = EyePos(), EyeAngles()
	local fwd = ang:Forward()
	local d = cameraData
	d.cx, d.cy, d.cz = __vunpack(org)
	d.fx, d.fy, d.fz = __vunpack(fwd)

	local client = LocalPlayer()
	local clientPos = client:GetShootPos()
	local frameTime = FrameTime()
	local curTime = CurTime()
	local profanity = GetConVar("echoes_profanity"):GetBool()
	local showRead = GetConVar("echoes_showread"):GetBool()
	local disableReadSys = GetConVar("echoes_disablereadsys"):GetBool()
	local curTimeSpeed = curTime * 1.5
	local showDlights = GetConVar("echoes_dlights"):GetBool()
	local enableAir = GetConVar("echoes_enableairechoes"):GetBool()
	local drawColor = Color(0, 0, 0)
	local targetLang = GetTranslateTargetLang()

	echoToGroundFrac = Lerp(frameTime * 2, echoToGroundFrac, enableAir and 0 or 1)

	surface.SetFont("TargetID") -- Set the font for text size calculations

	-- Compute squared distance to all echoes
	ComputeSqrEchoDist(clientPos)

	-- Update interactions with all echoes (relies on computed distances)
	UpdateEchoInteractions(echoes, curTimeSpeed, frameTime)

	-- Create a shallow copy of echoes and sort by distance (squared)
	local sortedEchoes = GetSortedVisibleEchoes()
	local echoCount = #sortedEchoes

	UpdateEchoRotations(sortedEchoes, frameTime)
	UpdateEchoTextCache(sortedEchoes)

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	for i = 1, echoCount do
		local echo = sortedEchoes[i]

		if (!echo.creationTime) then
			echo.creationTime = curTime + 0.01 * (echoCount - i)
		end

		if (echo.creationTime > curTime) then continue end

		local echoDistSqr = echo.distSqr
		local read = echo.read and !disableReadSys
		local bOwner = echo.isOwner
		if read and bOwner then read = false end

		-- Update initialization factor based on explicit flag and profanity setting
		if (read and !showRead) then
			echo.readTime = echo.readTime or curTime

			-- Fade out echo if it was read for more than 60 seconds
			if (curTime - echo.readTime > 60) then
				echo.init = math.max(echo.init - frameTime, 0)
			end
		else
			if ((echo.explicit and !profanity) or echo.failed) then
				echo.init = math.max(echo.init - frameTime, 0)
			elseif (echo.init < 1 and ((echo.explicit and profanity) or !echo.explicit) or disableReadSys) then
				echo.init = math.min(echo.init + frameTime, 1)
			end
		end

		if (echo.init == 0) then continue end -- Skip rendering if echo is not initialized

		local loading = echo.loading
		echo.z_offset = echo.z_offset or 0

		local ex,ey,ez = GetEchoPosition(echo)
		__vsetunpacked(echo.drawPos, ex,ey,ez + echo.z_offset)

		if (partyMode) then
			echo.partyOffsetLerp = echo.partyOffsetLerp or Vector()
			echo.partyOffsetLerp = LerpVector(frameTime * 3, echo.partyOffsetLerp, echo.partyOffset or vector_origin)
			__vadd(echo.drawPos, echo.partyOffsetLerp)
			lastPartyModeTime = curTime
		elseif lastPartyModeTime != 0 and curTime - lastPartyModeTime < 10 then -- for about 10 seconds after partymode, lerp party offset back to 0
			echo.partyOffsetLerp = echo.partyOffsetLerp or Vector()
			__vmul(echo.partyOffsetLerp, math.max(1 - frameTime * 3, 0))
			__vadd(echo.drawPos, echo.partyOffsetLerp)
		end

		local alpha = (math.Clamp((echoDistSqr - echoFadeDist / 2) / echoFadeDist, 0, 1) * 255) * echo.init
		local special = echo.special
		local active = echo.active
		local explicit = echo.explicit
		local translated = echo.originalText != nil

		-- Lazily detect the script/language of untranslated echoes (cached on the echo itself)
		if (echo._detectedLang == nil and !translated) then
			echo._detectedLang = DetectTextScript(echo.text) or "en" -- "en" = checked, plain ASCII / indeterminate Latin
		end

		local showTransIcon = ((echo._detectedLang and echo._detectedLang != targetLang) or translated)

		-- Render dynamic light if within render distance (using echo.pos for distance)
		-- Source can only handle 32 dynamic lights, so that's the limit we use, minus the number of map-created dynamic lights
		if (echoDistSqr <= lightRenderDist and showDlights and i >= (echoCount - (32 - dLightCount))) then
			local r = !read and !loading and (special and (200 + 55 * active) or explicit and 255 or bOwner and 255 or translated and (30 + 100 * active) or (100 + 100 * active)) or (120 + 135 * active)
			local g = !read and !loading and (special and (200 * active) or explicit and (50 + 150 * active) or bOwner and 255 or translated and (80 + 120 * active) or 255) or (120 + 135 * active)
			local b = !read and !loading and (special and (200 + 55 * active) or explicit and (50 + 150 * active) or bOwner and (200 * active) or translated and (180 + 75 * active) or 255) or (120 + 135 * active)

			local dLight = DynamicLight(echo.id)

			if (dLight) then
				dLight.Pos = echo.drawPos
				dLight.r = partyMode and echo.partyColor and echo.partyColor.r or r
				dLight.g = partyMode and echo.partyColor and echo.partyColor.g or g
				dLight.b = partyMode and echo.partyColor and echo.partyColor.b or b
				dLight.Brightness = 3
				dLight.Size = 256 * (((lightRenderDist - echoDistSqr) / lightRenderDist) * echo.init) * (alpha / 255)
				dLight.Decay = 1000
				dLight.DieTime = curTime + 0.1
			end
		end

		-- Draw the echo's texture and text
		local rDraw = !read and !loading and (special and (200 + 55 * active) or explicit and 255 or bOwner and 255 or translated and (30 + 100 * active) or (100 + 100 * active)) or (120 + 135 * active)
		local gDraw = !read and !loading and (special and (200 * active) or explicit and (50 + 150 * active) or bOwner and 255 or translated and (80 + 120 * active) or 255) or (120 + 135 * active)
		local bDraw = !read and !loading and (special and (200 + 55 * active) or explicit and (50 + 150 * active) or bOwner and (200 * active) or translated and (180 + 75 * active) or 255) or (120 + 135 * active)

		drawColor:SetUnpacked(rDraw, gDraw, bDraw, alpha)

		-- Main echo
		ComputeEchoMtx(echo_mtx, echo.drawPos, echo._angle, 0.1)
		cam.PushModelMatrix(echo_mtx, true)

		surface.SetDrawColor(partyMode and echo.partyColor or drawColor)
		surface.SetMaterial((loading or active > 0) and echoBlankMat or echoMat)
		surface.DrawTexturedRect(-96, -96, 192, 192)

		if (loading) then
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.SetMaterial(echoDotsMat)
			surface.DrawTexturedRectRotated(0, 0, 192, 192, curTime * -350)
		end

		if (alpha != 0 and active != 0) then
			cam.IgnoreZ(true)

			for j = 1, #echo.cachedText do
				draw.SimpleText(echo.cachedText[j], "TargetID", 1, -(150 + j * 15), Color(0, 0, 0, math.min(active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(echo.cachedText[j], "TargetID", 0, -(151 + j * 15), Color(255, 255, 255, math.min(active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			cam.IgnoreZ(false)
		end

		-- translate badge
		if (showTransIcon and alpha != 0) then
			local transColor = 100 + 155 * active
			surface.SetDrawColor(loading and Color(transColor, transColor, transColor, alpha) or partyMode and echo.partyColor or drawColor)
			surface.SetMaterial(echoTranslateMat)
			surface.DrawTexturedRect(16, -80, 64, 64)
		end

		cam.PopModelMatrix()

		-- Animated dots
		if (alpha != 0 and active != 0) then
			-- Scaled down matrix for better integer coordinate animation
			ComputeEchoMtx(echo_mtx, echo.drawPos, echo._angle, 0.01)
			cam.PushModelMatrix(echo_mtx, true)

			surface.SetMaterial(echoDotSingleMat)

			local z = (0.5 * math.sin(curTimeSpeed)) * active * 100
			surface.DrawTexturedRect(-1240, -960 + z, 1920, 1920)

			z = (0.5 * math.sin(curTimeSpeed + 20)) * active * 100
			surface.DrawTexturedRect(-960, -960 + z, 1920, 1920)

			z = (0.5 * math.sin(curTimeSpeed + 40)) * active * 100
			surface.DrawTexturedRect(-680, -960 + z, 1920, 1920)

			cam.PopModelMatrix()
		end
	end

	render.PopFilterMag()
	render.PopFilterMin()
end)

-- Translate the closest active echo
local wasTranslatePressed = false

hook.Add("Think", "echoes_translate_think", function()
	local client = LocalPlayer()
	local pressed = client:KeyDown(IN_WALK) and client:KeyDown(IN_USE)

	if (pressed and !wasTranslatePressed) then
		local clientPos = client:EyePos()
		local best, bestDist = nil, activationDist

		for i = 1, #echoes do
			local echo = echoes[i]
			if ((echo.active or 0) <= 0.9) then continue end

			local d = clientPos:DistToSqr(echo.pos)
			if (d >= bestDist) then continue end

			bestDist = d
			best = echo
		end

		if (best) then
			TranslateEcho(best)
		end
	end

	wasTranslatePressed = pressed
end)
