
-- Generic player setup
if (SERVER) then
	util.AddNetworkString("echoSetSpeed")

	-- Set player attributes
	hook.Add("PlayerSpawn", "player_PlayerSpawn", function(client)
		client:SetGravity(0.5)
		client:SetWalkSpeed(100)
		client:SetJumpPower(125)
		client:SetRunSpeed(client:GetWalkSpeed() * 2)
		client:SetCustomCollisionCheck(true)
		client:SetFriction(0.5)
		client:GodEnable()
		client:AllowFlashlight(true)

		-- Load position data. Only works on servers
		local mapName = game.GetMap()
		local mapData = file.Read("echoesbeyond/playerpos/" .. mapName .. ".txt", "DATA")
		mapData = util.JSONToTable(mapData and mapData != "" and mapData or "[]")

		local posData = mapData[client:SteamID()]

		if (posData) then
			client:SetPos(posData.position)
			client:SetAngles(posData.angles)
		end
	end)

	hook.Add("CanPlayerSuicide", "player_CanPlayerSuicide", function(client)
		return false
	end)

	-- Save position data locally. Only works on servers
	hook.Add("PlayerDisconnected", "player_PlayerDisconnected", function(client)
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
	end)

	-- Disable player collisions
	hook.Add("ShouldCollide", "player_ShouldCollide", function(entity1, entity2)
		if (entity1:IsPlayer() and entity2:IsPlayer()) then
			return false
		end
	end)

	net.Receive("echoSetSpeed", function(_, client)
		local speed = net.ReadFloat()

		client:SetWalkSpeed(speed)
		client:SetRunSpeed(speed * 2)
	end)
else
	CreateClientConVar("echoes_speed", "100")

	cvars.AddChangeCallback("echoes_speed", function(name, old, new)
		net.Start("echoSetSpeed")
			net.WriteFloat(tonumber(new))
		net.SendToServer()
	end, "echoes_speed")

	-- Don't render other players
	hook.Add("PrePlayerDraw", "player_PrePlayerDraw", function(client)
		return true
	end)
end

-- Disable footstep sounds
hook.Add("PlayerFootstep", "player_PlayerFootstep", function(client, position, foot, sound, volume, filter)
	return true
end)

-- Disable damage sounds
hook.Add("EntityEmitSound", "player_EntityEmitSound", function(soundData)
	if (!string.find(soundData.SoundName, "fallpain")) then return end

	return false -- Block the sound
end)
