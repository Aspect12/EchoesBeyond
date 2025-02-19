
-- Generic player setup
if (SERVER) then
	-- Set player attributes
	function GM:PlayerSpawn(client)
		client:SetGravity(0.85)
		client:SetWalkSpeed(100)
		client:SetRunSpeed(client:GetWalkSpeed() * 1.5)
		client:GodEnable()

		-- Load position data. Only works on servers
		local mapName = game.GetMap()
		local mapData = file.Read("echoesbeyond/playerpos/" .. mapName .. ".txt", "DATA")

		mapData = util.JSONToTable(mapData and mapData != "" and mapData or "[]")
		local posData = mapData[client:SteamID()]

		if (posData) then
			client:SetPos(posData.position)
			client:SetAngles(posData.angles)
		end
	end

	function GM:CanPlayerSuicide(client)
		return false
	end

	-- Save position data locally. Only works on servers
	function GM:PlayerDisconnected(client)
		local posData = {
			position = client:GetPos(),
			angles = client:GetAngles()
		}

		local mapName = game.GetMap()
		local mapData = file.Read("echoesbeyond/playerpos/" .. mapName .. ".txt", "DATA")

		mapData = util.JSONToTable(mapData and mapData != "" and mapData or "[]")
		mapData[client:SteamID()] = posData

		file.CreateDir("echoesbeyond/playerpos")
		file.Write("echoesbeyond/playerpos/" .. mapName .. ".txt", util.TableToJSON(mapData))
	end
else
	-- Don't render other players
	function GM:PrePlayerDraw(client, flags)
		return true
	end
end
