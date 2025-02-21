
-- Create notes
if (SERVER) then
	util.AddNetworkString("CreateNote")

	hook.Add("KeyPress", "notes_create_KeyPress", function(client, key)
		if (key != IN_RELOAD) then return end

		-- Prevent creating notes too close to any spawn points
		for _, spawn in ipairs(ents.FindByClass("info_player_start")) do
			if (client:GetShootPos():DistToSqr(spawn:GetPos()) >= 10000) then continue end

			EchoNotify(client, "A good message gives breathing room to those beyond. You are too close to a spawn point.")

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

		-- I kindly ask that you do not abuse this or act with malice.
		-- This game is meant to be a positive experience for everyone.
		-- Please do not ruin that for others.
		http.Post("https://hl2rp.net/echoes/submit.php", {
			ply = client:SteamID(),
			map = game.GetMap(),
			pos = position.x .. "," .. position.y .. "," .. position.z,
			text = message
		}, function(body, size, headers, code)
			FetchNotes()
		end)
	end

	net.Receive("CreateNote", function()
		local client = LocalPlayer()

		-- Prevent creating notes too close to other notes
		for _, note in ipairs(notes) do
			if (note.explicit) then continue end
			if (client:GetShootPos():DistToSqr(note.pos) >= 1500) then continue end

			EchoNotify("A good message needs an identity of its own. You are too close to another echo.")

			return
		end

		vgui.Create("echoEntry")
	end)
end
