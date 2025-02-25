
-- Create echoes
if (SERVER) then
	util.AddNetworkString("CreateNote")

	hook.Add("KeyPress", "echoes_create_KeyPress", function(client, key)
		if (key != IN_RELOAD) then return end

		-- Prevent creating echoes too close to any spawn points
		for _, spawn in ipairs(ents.FindByClass("info_player_start")) do
			if (client:GetShootPos():DistToSqr(spawn:GetPos()) >= 10000) then continue end

			EchoNotify(client, "A good message gives breathing room to those beyond. You are too close to a spawn point.")

			return
		end

		-- Prevent creating echoes outside the world
		if (!util.IsInWorld(client:GetPos())) then
			EchoNotify(client, "A good message is grounded in reality. You are outside the world.")

			return
		end

		-- Prevent creating echoes in the air
		if (!client:IsOnGround()) then
			EchoNotify(client, "A good message is built on solid ground. You are in the air.")

			return
		end

		net.Start("CreateNote")
		net.Send(client)
	end)
else
	function CreateNote(message)
		message = string.Trim(message)
		if (message == "") then return end

		local client = LocalPlayer()
		local position = client:GetPos() + Vector(0, 0, 32)
		local isOffensive = IsOffensive(message)

		-- I kindly ask that you do not abuse this or act with malice.
		-- This game is meant to be a positive experience for everyone.
		-- Please do not ruin that for others.
		http.Post("https://hl2rp.net/echoes/submit.php", {
			map = game.GetMap(),
			pos = position.x .. "," .. position.y .. "," .. position.z,
			explicit = isOffensive and "1" or "0",
			text = message,
		}, function(body, size, headers, code)
			FetchEchoes()

			-- If we're here, the echo was probably successfully created, so let's save it
			local savedEchoes = file.ReadOrCreate("echoesbeyond/writtenechoes.txt", "[]")

			savedEchoes[#savedEchoes + 1] = {
				map = game.GetMap(),
				pos = position,
				text = message,
				id = tonumber(body),
			}

			file.Write("echoesbeyond/writtenechoes.txt", util.TableToJSON(savedEchoes))

			if (isOffensive) then
				local profanity = GetConVar("echoes_profanity")

				profanity:SetBool(true)
			end
		end)
	end

	net.Receive("CreateNote", function()
		local ratelimit = nextEcho + 10 * #echoes

		if (ratelimit > os.time()) then
			EchoNotify("A good message bides its time. You must wait another " .. (string.NiceTime(ratelimit - os.time())) .. " before creating a new Echo.")

			return
		end

		if (mapRatelimit > os.time() and !mapList[game.GetMap()]) then
			EchoNotify("Uncharted territory must be explored with care. You must wait another " .. (string.NiceTime(mapRatelimit - os.time())) .. " before creating an Echo on a new map.")

			return
		end

		local client = LocalPlayer()

		-- Prevent creating echoes too close to other echoes
		for _, echo in ipairs(echoes) do
			if (echo.explicit) then continue end
			if ((client:GetPos() + Vector(0, 0, 32)):DistToSqr(echo.pos) >= 1000) then continue end

			EchoNotify("A good message needs an identity of its own. You are too close to another Echo.")

			return
		end

		vgui.Create("echoEntry")
	end)
end
