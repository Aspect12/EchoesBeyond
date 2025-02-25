
-- Fetch echoes and send them to the client
CreateClientConVar("echoes_windowflash", "1")

-- Initialize globals
mapCount = mapCount or 0 -- Total amount of maps with echoes, used in the main menu
writtenEchoes = writtenEchoes or {} -- Echoes on the map written by the player
readEchoCount = readEchoCount or 0 -- Amount of echoes read by the player
globalEchoCount = globalEchoCount or 0 -- Total amount of echoes, ditto
userCount = userCount or 0 -- Total amount of users, ditto
nextEcho = nextEcho or 0 -- Time a new echo can be made
mapList = mapList or {} -- List of maps with echoes
echoes = echoes or {} -- Echoes on the map

function FetchEchoes()
	local map = game.GetMap()

	http.Fetch("https://resonance.flatgrass.net/note/view?map=" .. map, function(body, _, _, code)
		if (code != 200) then
			EchoNotify("RESONANCE ERROR: " .. string.sub(body, 1, -2))

			return
		end

		local data = util.JSONToTable(body) or {}
		local echoData = data.notes
		if (!echoData) then return end

		local readEchoes = file.ReadOrCreate("echoesbeyond/readechoes.txt")
		local echoCount = #echoData

		if (echoCount > #echoes) then
			LocalPlayer():EmitSound("echoesbeyond/echo_create.wav", 75, math.random(95, 105))

			if (GetConVar("echoes_windowflash"):GetBool()) then
				system.FlashWindow()
			end
		end

		if (IsValid(mainMenu)) then
			mainMenu:UpdateStats(nil, #echoData)
		end

		readEchoCount = 0

		for i = 1, #echoData do
			local newEcho = echoData[i]
			local exists = false

			for k = 1, #echoes do
				if (echoes[k].id != newEcho.id) then continue end

				exists = true

				break
			end

			local read = table.HasValue(readEchoes, newEcho.id)
			local isOwner = false

			for k = 1, #writtenEchoes do
				if (writtenEchoes[k].id != newEcho.id) then continue end

				isOwner = true

				break
			end

			if (read or isOwner) then
				readEchoCount = readEchoCount + 1
			end

			if (exists) then continue end

			local position = Vector(tonumber(newEcho.position[1]), tonumber(newEcho.position[2]), tonumber(newEcho.position[3]))
			local text = newEcho.comment
			local read = table.HasValue(readEchoes, newEcho.id)

			echoes[#echoes + 1] = {
				explicit = IsOffensive(text),
				readTime = read and 0,
				special = newEcho.special,
				angle = Angle(0, 0, 90),
				soundActive = false,
				drawPos = position,
				isOwner = isOwner,
				id = newEcho.id,
				pos = position,
				read = read,
				text = text,
				active = 0,
				init = 0
			}
		end
	end, function(error)
		EchoNotify(error)
	end)
end

function FetchOwnEchoes()
	http.Fetch("https://resonance.flatgrass.net/note/mine", function(body, _, _, code)
		if (authToken) then
			if (code != 200) then
				EchoNotify("RESONANCE ERROR: " .. string.sub(body, 1, -2))

				return
			end

			local data = util.JSONToTable(body) or {}
			local echoData = data.notes
			if (!echoData) then return end

			writtenEchoes = echoData
		end

		FetchEchoes()
	end, function(error)
		EchoNotify(error)
	end, {authorization = authToken})
end

function FetchStats()
	http.Fetch("https://resonance.flatgrass.net/stats", function(body, _, _, code)
		if (code != 200) then
			EchoNotify("RESONANCE ERROR: " .. string.sub(body, 1, -2))

			return
		end

		local data = util.JSONToTable(body)
		if (!data) then return end

		if (IsValid(mainMenu)) then
			mainMenu:UpdateStats(data.user_count, data.note_count, data.map_count, data.maps)
		end

		userCount = data.user_count
		globalEchoCount = data.note_count
		mapCount = data.map_count
		mapList = data.maps

	end, function(error)
		EchoNotify(error)
	end)
end

function FetchInfo()
	if (!authToken) then return end

	http.Fetch("https://resonance.flatgrass.net/info?map=" .. game.GetMap(), function(body, _, _, code)
		if (code != 200) then
			EchoNotify("RESONANCE ERROR: " .. string.sub(body, 1, -2))

			return
		end

		local data = util.JSONToTable(body)
		if (!data) then return end

		nextEcho = os.time() + data.note_cooldown
	end, function(error)
		EchoNotify(error)
	end, {authorization = authToken})
end

hook.Add("InitPostEntity", "echoes_fetch_InitPostEntity", function()
	authToken = file.Read("echoesbeyond/authtoken.txt", "DATA")
	authToken = authToken and string.find(authToken, "\n", 1, true) and string.Explode("\n", authToken)[2]

	FetchOwnEchoes()
	FetchInfo()

	-- Fetch echoes & info every minute
	timer.Create("echoesFetchEchoes", 60, 0, function() FetchEchoes() FetchInfo() end)
end)
