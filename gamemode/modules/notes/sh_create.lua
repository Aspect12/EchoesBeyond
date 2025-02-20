
-- Create notes
if (SERVER) then
	util.AddNetworkString("CreateNote")
	util.AddNetworkString("RegisterNote")

	hook.Add("KeyPress", "notes_create_KeyPress", function(client, key)
		if (key != IN_RELOAD) then return end

		-- Prevent creating notes too close to other notes
		for _, note in ipairs(notes) do
			if (client:GetShootPos():DistToSqr(note.pos) < 1500) then
				EchoNotify(client, "A good message needs an identity of its own. You are too close to another echo.")

				return
			end
		end

		-- Prevent creating notes too close to any spawn points
		for _, spawn in ipairs(ents.FindByClass("info_player_start")) do
			if (client:GetShootPos():DistToSqr(spawn:GetPos()) < 10000) then
				EchoNotify(client, "A good message gives breathing room to those beyond. You are too close to a spawn point.")

				return
			end
		end

		net.Start("CreateNote")
		net.Send(client)
	end)

	net.Receive("CreateNote", function(_, client)
		local text = net.ReadString()

		text = text:Trim()
		if (text == "") then return end

		-- Prevent creating notes too close to other notes. Also here in case of net manipulation
		for _, note in ipairs(notes) do
			if (client:GetShootPos():DistToSqr(note.pos) < 1500) then
				EchoNotify(client, "A good message marks its own origin. You are too close to another echo.")

				return
			end
		end

		-- Prevent creating notes too close to any spawn points. Also here in case of net manipulation
		for _, spawn in ipairs(ents.FindByClass("info_player_start")) do
			if (client:GetShootPos():DistToSqr(spawn:GetPos()) < 10000) then
				EchoNotify(client, "A good message gives breathing room to those beyond. You are too close to a spawn point.")

				return
			end
		end

		local position = client:GetPos() + Vector(0, 0, 32)

		text = text:gsub("\n", " ") -- Remove newlines
		text = text:sub(1, 512) -- Limit text length

		local explicit = IsOffensive(text)

		notes[#notes + 1] = {
			ply = client:SteamID(),
			explicit = explicit,
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
			net.WriteBool(explicit)
			net.WriteString(text)
		net.Broadcast()
	end)
else
	net.Receive("CreateNote", function()
		vgui.Create("echoEntry")
	end)

	net.Receive("RegisterNote", function()
		local id = net.ReadUInt(31)
		local position = net.ReadVector()
		local client = net.ReadPlayer()
		local explicit = net.ReadBool()
		local text = net.ReadString()

		notes[#notes + 1] = {
			ply = client:SteamID(),
			soundActive = false,
			explicit = explicit,
			drawPos = position,
			pos = position,
			text = text,
			active = 0,
			init = 0,
			id = id
		}

		LocalPlayer():EmitSound("echoesbeyond/note_create.wav", 75, math.random(95, 105))

		-- Save own notes
		if (client != LocalPlayer()) then return end

		-- If we wrote something explicit, turn off the profanity filter
		if (explicit) then
			local profanity = GetConVar("echoes_profanity")

			profanity:SetBool(true)
		end

		local savedNotes = file.Read("echoesbeyond/writtennotes.txt", "DATA")
		savedNotes = util.JSONToTable(savedNotes and savedNotes != "" and savedNotes or "[]")

		savedNotes[#savedNotes + 1] = {
			explicit = explicit,
			map = game.GetMap(),
			pos = position,
			text = text,
			id = id
		}

		file.CreateDir("echoesbeyond")
		file.Write("echoesbeyond/writtennotes.txt", util.TableToJSON(savedNotes))
	end)
end
