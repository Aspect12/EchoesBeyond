
-- Completely isolated feature, so I figured it deserves its own file

local pulse = nil
local flash = nil

local function GetClosestUnreadEcho(origin)
	local renderVoidEchoes = GetConVar("echoes_enablevoidechoes"):GetBool()
	local renderAirEchoes = GetConVar("echoes_enablefloatingechoes"):GetBool()
	local closest, closestDist

	for _, echo in ipairs(echoes) do
		if (echo.read or echo.isOwner or echo.special or echo.loading) then continue end
		if (echo.timeHidden or (echo.inVoid and !renderVoidEchoes) or (echo.inAir and !renderAirEchoes)) then continue end

		local dist = origin:Distance(echo.pos)
		if (closestDist and dist >= closestDist) then continue end

		closest, closestDist = echo, dist
	end

	return closest, closestDist
end

local function IsTranslated(echo)
	return (echo._detectedLang and echo._detectedLang != GetEchoTranslateTargetLang()) or echo.originalText
end

-- technically only translated & explicit echoes get their own color so we can ignore the rest
local function GetEchoColor(echo)
	if (echo.explicit) then return Color(255, 50, 50) end
	if (IsTranslated(echo)) then return Color(30, 80, 180) end

	return Color(3, 205, 255)
end

local incoming = nil
local pulseSpeed = 1000 -- the speed of the pulse
local pulseFadeTime = 0.5 -- how long the pulse keeps fading after reaching its end
local maxDist = 100
local gabenHiSounds = {
	"echoesbeyond/gaben/al_hi.wav",
	"echoesbeyond/gaben/l4d_hi.wav",
	"echoesbeyond/gaben/l4d2_hi.wav",
	"echoesbeyond/gaben/lc_hi.wav",
	"echoesbeyond/gaben/p2_hi.wav"
}

hook.Add("Think", "echoes_locate_Think", function()
	local curTime = RealTime()

	if (incoming and (curTime - incoming.start) * pulseSpeed >= incoming.range + pulseSpeed * pulseFadeTime) then
		incoming = nil
	end

	if (pulse) then
		local radius = (curTime - pulse.start) * pulseSpeed

		if (pulse.echo and radius >= pulse.range) then
			local echo = pulse.echo
			local color = GetEchoColor(echo)
			local clientPos = EyePos()
			local pos = echo.pos

			incoming = {origin = echo.pos, start = curTime, range = echo.pos:Distance(clientPos), color = color}
			flash = {pos = pos, start = curTime, color = color}

			-- set a max pos away from the player so the audio direction still works
			if (pos:Distance(clientPos) > maxDist) then
				pos = clientPos + (pos - clientPos):GetNormalized() * maxDist
			end

			local pitch = echo.explicit and math.random(65, 75) or IsTranslated(echo) and math.random(105, 115) or math.random(95, 105)

			if (GetConVar("echoes_gabenmode"):GetBool()) then
				EmitSound(gabenHiSounds[math.random(#gabenHiSounds)], pos, 0, nil, nil, 150, nil, pitch)
			else
				EmitSound("echoesbeyond/echolocator_" .. math.random(5) .. ".wav", pos, 0, nil, nil, 150, nil, pitch)
			end

			pulse.echo = nil
		end

		if (radius >= pulse.range + pulseSpeed * pulseFadeTime) then
			pulse = nil
		end
	end

	if (!flash or curTime - flash.start <= 1) then return end

	flash = nil
end)

local function DrawPulse(data, color, inverted)
	local radius = (RealTime() - data.start) * pulseSpeed
	local alpha = 60 * (1 - math.Clamp(radius / (data.range + pulseSpeed * pulseFadeTime), 0, 1))

	if (alpha < 1) then return end

	render.SetColorMaterial()
	render.DrawSphere(data.origin, inverted and -radius or radius, 50, 50, Color(color.r, color.g, color.b, alpha))

	-- render twice if not inverted so we can see it after it passes us
	if (inverted) then return end

	DrawPulse(data, color, true)
end

hook.Add("PostDrawTranslucentRenderables", "echoes_locate_PostDrawTranslucentRenderables", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end
	if (pulse) then DrawPulse(pulse, Color(3, 205, 255), true) end
	if (incoming) then DrawPulse(incoming, incoming.color, false) end
end)

local gradientMats = {
	left = Material("vgui/gradient-l"),
	right = Material("vgui/gradient-r"),
	top = Material("vgui/gradient-u"),
	bottom = Material("vgui/gradient-d")
}

local spriteSize = 256
local gradientSize = 256
local glowMaterial = Material("sprites/light_glow02_add")

hook.Add("HUDPaint", "echoes_locate_HUDPaint", function()
	if (!flash) then return end

	local width, height = ScrW(), ScrH()
	local fraction = 1 - (RealTime() - flash.start)
	local screen = flash.pos:ToScreen()
	local color = flash.color
	local size = spriteSize * fraction

	-- on-screen glow
	if (screen.visible and screen.x >= 0 and screen.x <= width and screen.y >= 0 and screen.y <= height) then
		surface.SetMaterial(glowMaterial)
		surface.SetDrawColor(color.r, color.g, color.b)
		surface.DrawTexturedRect(screen.x - size / 2, screen.y - size / 2, size, size)

		return
	end

	-- off-screen gradient
	local dir = flash.pos - EyePos()
	local ang = EyeAngles()
	local right, up = dir:Dot(ang:Right()), dir:Dot(ang:Up())
	local side

	if (math.abs(right) > math.abs(up)) then
		side = right > 0 and "right" or "left"
	else
		side = up > 0 and "top" or "bottom"
	end

	local material = gradientMats[side]
	if (!material) then return end

	local alpha = 255 * fraction * fraction

	surface.SetMaterial(material)
	surface.SetDrawColor(color.r, color.g, color.b, alpha * 0.75)

	if (side == "left") then
		surface.DrawTexturedRect(0, 0, gradientSize, height)
	elseif (side == "right") then
		surface.DrawTexturedRect(width - gradientSize, 0, gradientSize, height)
	elseif (side == "top") then
		surface.DrawTexturedRect(0, 0, width, gradientSize)
	else
		surface.DrawTexturedRect(0, height - gradientSize, width, gradientSize)
	end
end)

-- 2 sec cooldown
local lastLocate = 0

hook.Add("PlayerBindPress", "echoes_locate_PlayerBindPress", function(client, bind, pressed, code)
	if (bind != "+menu" or !input.IsKeyDown(KEY_LALT)) then return end
	if (RealTime() - lastLocate < 2) then return end

	local origin = EyePos()
	local echo, dist = GetClosestUnreadEcho(origin)

	pulse = {
		origin = origin,
		start = RealTime(),
		echo = echo,
		range = dist or 5000 -- fallback dist
	}

	lastLocate = RealTime()

	if (GetConVar("echoes_gabenmode"):GetBool()) then
		LocalPlayer():EmitSound(gabenHiSounds[math.random(#gabenHiSounds)], nil, math.random(95, 105))
	else
		LocalPlayer():EmitSound("echoesbeyond/echolocator_" .. math.random(5) .. ".wav", nil, math.random(95, 105))
	end
end)
