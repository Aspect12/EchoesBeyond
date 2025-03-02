
-- Handles teleporting
if (SERVER) then
	util.AddNetworkString("echoTeleport")

	net.Receive("echoTeleport", function(_, client)
		local pos = net.ReadVector()

		client:SetPos(pos)
		EchoNotify(client, "You have teleported to the location of the target Echo.")
	end)
else
	hook.Add("InitPostEntity", "teleport_InitPostEntity", function()
		local teleportData = file.Read("echoesbeyond/teleport.json", "DATA") or ""
		teleportData = util.JSONToTable(teleportData)
		if (!teleportData) then return end

		if (teleportData.map != game.GetMap()) then return end

		net.Start("echoTeleport")
			net.WriteVector(teleportData.pos)
		net.SendToServer()

		file.Delete("echoesbeyond/teleport.json")
	end)
end
