
-- Fetch notes from server and send them to the clients
if (SERVER) then
	util.AddNetworkString("FetchNotes")

	-- Add saved notes
	function GM:Initialize()
		if (!file.Exists("echoesbeyond/notes.txt", "DATA")) then return end

		notes = util.JSONToTable(file.Read("echoesbeyond/notes.txt", "DATA"))
	end

	-- Send notes to client on join
	net.Receive("FetchNotes", function(_, client)
		net.Start("FetchNotes")
			net.WriteTable(notes)
		net.Send(client)
	end)
else
	-- Fetch notes on join
	function GM:InitPostEntity()
		net.Start("FetchNotes")
		net.SendToServer()
	end

	net.Receive("FetchNotes", function()
		notes = net.ReadTable()

		for i = 1, #notes do
			notes[i].drawPos = notes[i].pos
			notes[i].active = 0
			notes[i].init = 1
		end
	end)
end
