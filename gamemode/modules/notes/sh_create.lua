
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

		-- Enforce echo uniqueness
		for _, echo in ipairs(echoes) do
			if (string.lower(message) != string.lower(message)) then continue end

			EchoNotify("A good message does not get lost in the noise. Your Echo must be unique.")

			return
		end

		local client = LocalPlayer()
		local position = client:GetPos() + Vector(0, 0, 32)
		local isOffensive = IsOffensive(message)

		http.Post("https://resonance.flatgrass.net/note/create", {
			map = game.GetMap(),
			pos = position.x .. "," .. position.y .. "," .. position.z,
			comment = message
		}, function(body, _, _, code)
			if (code != 200) then
				EchoNotify("ERROR: " .. body)

				return
			end

			FetchOwnEchoes()
			FetchInfo()

			if (isOffensive) then
				local profanity = GetConVar("echoes_profanity")

				profanity:SetBool(true)
			end
		end, nil, {authorization = authToken})
	end

	net.Receive("CreateNote", function()
		if (!authToken) then
			vgui.Create("echoAuthMenu")

			return
		end

		if (nextEcho > os.time()) then
			EchoNotify("A good message bides its time. You must wait another " .. (string.NiceTime(nextEcho - os.time())) .. " before creating a new Echo.")

			return
		end

		local client = LocalPlayer()

		-- Prevent creating echoes too close to other echoes
		for _, echo in ipairs(echoes) do
			if (echo.explicit) then continue end
			if ((client:GetPos() + Vector(0, 0, 32)):Distance(echo.pos) >= 75) then continue end

			EchoNotify("A good message needs an identity of its own. You are too close to another Echo.")

			return
		end

		vgui.Create("echoEntry")
	end)
end
