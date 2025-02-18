
-- Save notes, player positions, and player intro info, play ambient music, improve note creation popup

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("CreateNote")
util.AddNetworkString("FetchNotes")
util.AddNetworkString("RegisterNote")

-- Set speed & gravity
function GM:PlayerSpawn(client)
	client:SetGravity(0.85)
	client:SetWalkSpeed(100)
	client:SetRunSpeed(client:GetWalkSpeed() * 1.5)
	client:GodEnable()
end

-- Create notes
function GM:KeyPress(client, key)
	if (key != IN_USE) then return end

	local position = client:GetPos() + Vector(0, 0, 32)

	net.Start("CreateNote")
		net.WriteVector(position)
	net.Send(client)
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

net.Receive("CreateNote", function(_, client)
	local position = net.ReadVector()
	local text = net.ReadString()

	text = text:Trim()
	if (text == "") then return end

	text = text:sub(1, 255) -- Limit text length

	notes[#notes + 1] = {
		pos = position,
		ply = client,
		text = text
	}

	net.Start("RegisterNote")
		net.WriteVector(position)
		net.WritePlayer(client)
		net.WriteString(text)
	net.Broadcast()
end)
