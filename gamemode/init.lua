
-- save player positions
-- save player intro info
-- play ambient music
-- decorate note creation popup
-- play sound on note creation
-- play sound on note activation
-- save note 'check' state (unchecked = blue, checked = white)
-- give notes ids (curTime)

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("CreateNote")
util.AddNetworkString("FetchNotes")
util.AddNetworkString("RegisterNote")
util.AddNetworkString("PlayPlayerSound")

-- Add saved notes
function GM:Initialize()
	if (!file.Exists("echoesbeyond/notes.txt", "DATA")) then return end

	notes = util.JSONToTable(file.Read("echoesbeyond/notes.txt", "DATA"))
end

-- Play join/leave sound
function GM:PlayerInitialSpawn(client)
	net.Start("PlayPlayerSound")
		net.WriteBool(true)
	net.Broadcast()
end

function GM:PlayerDisconnected(client)
	net.Start("PlayPlayerSound")
		net.WriteBool(false)
	net.Broadcast()
end


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

-- Create notes
net.Receive("CreateNote", function(_, client)
	local position = net.ReadVector()
	local text = net.ReadString()

	text = text:Trim()
	if (text == "") then return end

	text = text:sub(1, 255) -- Limit text length

	notes[#notes + 1] = {
		pos = position,
		ply = client:SteamID(),
		text = text
	}

	file.CreateDir("echoesbeyond")
	file.Write("echoesbeyond/notes.txt", util.TableToJSON(notes))

	net.Start("RegisterNote")
		net.WriteVector(position)
		net.WritePlayer(client)
		net.WriteString(text)
	net.Broadcast()
end)
