
CreateClientConVar("echoes_showread", "1")
CreateClientConVar("echoes_renderdist", "25000000")

local echoMat = Material("echoesbeyond/echo.png", "mips")
local echoBlankMat = Material("echoesbeyond/echo_blank.png", "mips")
local echoDotsMat = Material("echoesbeyond/echo_dots.png", "mips")
local echoDotSingleMat = Material("echoesbeyond/echo_dot_single.png", "mips")
local lightRenderDist = 3000000 -- How far the dynamic light should render
local activationDist = 6500 -- How close the player should be to activate the echo
local echoFadeDist = 2500 -- How far the echo should start fading

hook.Add("PostDrawTranslucentRenderables", "echoes_render_Combined", function(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	local client = LocalPlayer()
	local clientPos = client:GetShootPos()
	local frameTime = FrameTime()
	local curTime = CurTime()
	local profanity = GetConVar("echoes_profanity"):GetBool()
	local showRead = GetConVar("echoes_showread"):GetBool()
	local cutOffDist = GetConVar("echoes_renderdist"):GetInt()
	local lerpFactor = math.Clamp(frameTime * 5, 0, 1)
	local curTimeSpeed = curTime * 1.5
	local breathLayer = math.sin(curTimeSpeed) * 0.5
	local activationOffset = Vector(0, 0, 24 + breathLayer)
	local readOffset = Vector(0, 0, 20)

	surface.SetFont("CenterPrintText")

	-- Create a shallow copy of echoes and sort by distance (squared)
	local sortedEchoes = {}
	local fixedI = 1

	for i = 1, #echoes do
		if (echoes[i].creationTime > curTime) then continue end

		local distToSqr = clientPos:DistToSqr(echoes[i].pos)
		if (distToSqr > cutOffDist) then continue end

		sortedEchoes[fixedI] = echoes[i]
		sortedEchoes[fixedI].distSqr = distToSqr

		fixedI = fixedI + 1
	end

	table.sort(sortedEchoes, function(a, b)
		return a.distSqr > b.distSqr
	end)

	for i = 1, #sortedEchoes do
		local echo = sortedEchoes[i]
		local echoDistSqr = clientPos:DistToSqr(echo.pos)
		local read = echo.read
		local bOwner = echo.isOwner

		-- Update angle (smooth rotation)
		local ang = (clientPos - echo.pos):Angle()

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)
		ang = Angle(ang.p, ang.y, 90)

		echo.angle = LerpAngle(lerpFactor, echo.angle, ang)

		-- Update initialization factor based on explicit flag and profanity setting
		if (read and !showRead) then
			if (!echo.readTime) then
				echo.readTime = curTime
			end

			-- Fade out echo if it was read for more than 60 seconds
			if (curTime - echo.readTime > 60) then
				echo.init = math.max(echo.init - frameTime, 0)
			end
		else
			if ((echo.explicit and !profanity) or echo.failed) then
				echo.init = math.max(echo.init - frameTime, 0)
			elseif (echo.init < 1 and (echo.explicit and profanity) or !echo.explicit) then
				echo.init = math.min(echo.init + frameTime, 1)
			end
		end

		if (echo.init == 0) then continue end -- Skip rendering if echo is not initialized

		local loading = echo.loading

		-- Activate echo if within activation distance
		if (((echo.explicit and profanity) or !echo.explicit) and !loading) then
			if (echoDistSqr < activationDist) then
				local active = math.min(echo.active + frameTime * 3, 1)

				echo.active = active
				echo.drawPos = LerpVector(frameTime * 3, echo.drawPos, echo.pos + activationOffset)

				if (!echo.soundActive) then
					echo.soundActive = true

					EchoSound("echo_activate", echo.special and math.random(115, 125) or echo.explicit and math.random(65, 75) or math.random(95, 105))
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
				echo.active = math.max(echo.active - frameTime * 0.5, 0)
				echo.drawPos = LerpVector(frameTime * 1.5, echo.drawPos, echo.pos - (echo.read and readOffset or Vector(0, 0, 0)))

				if (echo.soundActive) then
					echo.soundActive = false
				end
			end
		end

		local alpha = (math.Clamp((echoDistSqr - echoFadeDist / 2) / echoFadeDist, 0, 1) * 255) * echo.init

		local special = echo.special
		local active = echo.active
		local explicit = echo.explicit

		-- Render dynamic light if within render distance (using echo.pos for distance)
		if (echoDistSqr <= lightRenderDist and GetConVar("echoes_dlights"):GetBool() and i >= (#sortedEchoes - (32 - dLightCount))) then -- Source can only handle 32 dynamic lights, so that's the
			local r = !read and !loading and (special and 255 or explicit and 255 or bOwner and 255 or (100 + 155 * active)) or (25 + 230 * active) -- limit we use, minus the number of map-created dynamic lights
			local g = !read and !loading and (special and (255 * active) or explicit and (25 + 230 * active) or bOwner and 255 or 255) or (25 + 230 * active)
			local b = !read and !loading and (special and 255 or explicit and (25 + 230 * active) or bOwner and (255 * active) or 255) or (25 + 230 * active)

			local dLight = DynamicLight(i)

			if (dLight) then
				dLight.Pos = echo.drawPos
				dLight.r = r
				dLight.g = g
				dLight.b = b
				dLight.Brightness = 3
				dLight.Size = 256 * (((lightRenderDist - echoDistSqr) / lightRenderDist) * echo.init) * (alpha / 255)
				dLight.Decay = 1000
				dLight.DieTime = curTime + 0.1
			end
		end

		-- Cache wrapped text to avoid recalculations
		if (!echo.cachedText) then
			local words = string.Explode(" ", echo.text)
			local lines = {}
			local line = ""

			for j = 1, #words do
				local word = words[j]

				if (surface.GetTextSize(line .. " " .. word) > 512) then
					table.insert(lines, line)

					line = word
				else
					line = (line == ""and word or line .. " " .. word)
				end
			end

			table.insert(lines, line)

			for j = 1, math.floor(#lines / 2)do
				lines[j], lines[#lines - j + 1] = lines[#lines - j + 1], lines[j]
			end

			echo.cachedText = lines
		end

		-- Draw the echo's texture and text
		local rDraw = !read and !loading and (special and (200 + 55 * active) or explicit and 255 or bOwner and 255 or (150 + 105 * active)) or (100 + 155 * active)
		local gDraw = !read and !loading and (special and (255 * active) or explicit and (50 + 205 * active) or bOwner and 255 or 255) or (100 + 155 * active)
		local bDraw = !read and !loading and (special and (200 + 55 * active) or explicit and (50 + 205 * active) or bOwner and (255 * active) or 255) or (100 + 155 * active)

		cam.Start3D2D(echo.drawPos, echo.angle, 0.1)
			surface.SetDrawColor(rDraw, gDraw, bDraw, alpha)
			surface.SetMaterial(active == 0 and echoMat or echoBlankMat)
			surface.DrawTexturedRect(-96, -96, 192, 192)

			if (loading) then
				surface.SetDrawColor(0, 0, 0, alpha)
				surface.SetMaterial(echoDotsMat)
				surface.DrawTexturedRectRotated(0, 0, 192, 192, curTime * -350)
			end

			if (alpha == 0 or active == 0) then cam.End3D2D() continue end

			for j = 1, #echo.cachedText do
				draw.SimpleText(echo.cachedText[j], "TargetID", 1, -(150 + j * 15), Color(0, 0, 0, math.min(active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(echo.cachedText[j], "TargetID", 0, -(151 + j * 15), Color(255, 255, 255, math.min(active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()

		surface.SetMaterial(echoDotSingleMat)

		-- I don't like this, but it's the only way they can be smooth.
		cam.Start3D2D(echo.drawPos + Vector(0, 0, (0.5 * math.sin(curTimeSpeed)) * active), echo.angle, 0.1)
			surface.DrawTexturedRect(-124, -96, 192, 192)
		cam.End3D2D()

		cam.Start3D2D(echo.drawPos + Vector(0, 0, (0.5 * math.sin(curTimeSpeed + 20)) * active), echo.angle, 0.1)
			surface.DrawTexturedRect(-96, -96, 192, 192)
		cam.End3D2D()

		cam.Start3D2D(echo.drawPos + Vector(0, 0, (0.5 * math.sin(curTimeSpeed + 40)) * active), echo.angle, 0.1)
			surface.DrawTexturedRect(-68, -96, 192, 192)
		cam.End3D2D()
	end
end)
