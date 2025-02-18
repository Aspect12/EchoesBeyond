
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("CreateNote")
util.AddNetworkString("FetchNotes")

-- Set speed & gravity
function GM:PlayerSpawn(client)
	client:SetGravity(0.85)
	client:SetWalkSpeed(100)
	client:SetRunSpeed(client:GetWalkSpeed() * 1.5)
end

-- Create notes
function GM:KeyPress(client, key)
	if (key != IN_USE) then return end

	local position = client:GetPos() + Vector(0, 0, 32)

	notes[#notes + 1] = {
		pos = position,
		text = ""
	}

	net.Start("CreateNote")
		net.WriteVector(position)
	net.Broadcast()
end

-- Send notes to client on join
net.Receive("FetchNotes", function(_, client)
	net.Start("FetchNotes")
		net.WriteTable(notes)
	net.Send(client)
end)

function GM:CanPlayerSuicide(client)
	return false
end
