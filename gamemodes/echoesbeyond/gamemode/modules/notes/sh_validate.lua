
if (SERVER) then
	util.AddNetworkString("echoValidateEchoes")

	net.Receive("echoValidateEchoes", function(_, client)
		local echoes = net.ReadTable()
		local response = {}

		for i = 1, #echoes do
			local echo = echoes[i]
			local echoID = echo.id
			local echoPos = echo.pos

			if (util.IsInWorld(echoPos)) then continue end

			response[echoID] = true
		end

		net.Start("echoValidateEchoes")
			net.WriteTable(response)
		net.Send(client)
	end)
else
	net.Receive("echoValidateEchoes", function()
		local response = net.ReadTable()
		if (table.Count(response) == 0) then return end

		local newEchoes = {}

		for i = 1, #echoes do
			local echo = echoes[i]
			local echoID = echo.id

			if (response[echoID]) then continue end

			newEchoes[#newEchoes + 1] = echo
		end

		echoes = newEchoes
	end)
end
