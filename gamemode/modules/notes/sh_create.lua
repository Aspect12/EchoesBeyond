
-- Create notes
if (SERVER) then
	util.AddNetworkString("CreateNote")
	util.AddNetworkString("RegisterNote")

	function GM:KeyPress(client, key)
		if (key != IN_USE) then return end

		net.Start("CreateNote")
		net.Send(client)
	end

	net.Receive("CreateNote", function(_, client)
		local text = net.ReadString()

		text = text:Trim()
		if (text == "") then return end

		local position = client:GetPos() + Vector(0, 0, 32)
		text = text:sub(1, 512) -- Limit text length

		notes[#notes + 1] = {
			ply = client:SteamID(),
			id  = os.time(),
			pos = position,
			text = text
		}

		file.CreateDir("echoesbeyond")
		file.Write("echoesbeyond/notes.txt", util.TableToJSON(notes))

		net.Start("RegisterNote")
			net.WriteUInt(notes[#notes].id, 31)
			net.WriteVector(position)
			net.WritePlayer(client)
			net.WriteString(text)
		net.Broadcast()
	end)
else
	net.Receive("CreateNote", function()
		Derma_StringRequest("Create Echo", "Write your echo below (512 char limit)...", nil, function(message)
			net.Start("CreateNote")
				net.WriteString(message)
			net.SendToServer()
		end, nil, "Echo")
	end)

	net.Receive("RegisterNote", function()
		local id = net.ReadUInt(31)
		local position = net.ReadVector()
		local client = net.ReadPlayer()
		local text = net.ReadString()

		notes[#notes + 1] = {
			ply = client:SteamID(),
			drawPos = position,
			pos = position,
			text = text,
			active = 0,
			init = 0,
			id = id
		}
	end)
end
