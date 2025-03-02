
-- Validates new Echoes
if (SERVER) then
	util.AddNetworkString("echoValidateEchoes")

	net.Receive("echoValidateEchoes", function(_, client)
		local echoList = net.ReadTable()
		local voidResponse = {}
		local airResponse = {}

		for i = 1, #echoList do
			local echo = echoList[i]
			local echoID = echo.id
			local echoPos = echo.pos

			local trace = util.TraceLine({
				start = echoPos,
				endpos = echoPos + Vector(0, 0, -9999999)
			})

			if (util.IsInWorld(echoPos)) then
				if (echoPos:DistToSqr(trace.HitPos) <= 1050) then continue end
				airResponse[echoID] = trace.HitPos + Vector(0, 0, 32)
			else
				voidResponse[echoID] = true
			end
		end

		net.Start("echoValidateEchoes")
			net.WriteTable(voidResponse)
			net.WriteTable(airResponse)
		net.Send(client)
	end)
else
	CreateClientConVar("echoes_enablevoidechoes", "0")
	CreateClientConVar("echoes_enableairechoes", "1")

	cvars.AddChangeCallback("echoes_enableairechoes", function(name, old, new)
		for _, echo in pairs(echoes) do
			if (!echo.airPos) then continue end

			if (new == "1") then
				echo.pos = echo.ogPos
			else
				echo.pos = echo.airPos
			end
		end
	end, "echoes_enableairechoes")

	net.Receive("echoValidateEchoes", function()
		local voidResponse = net.ReadTable()

		-- Hide echoes in the void
		if (table.Count(voidResponse) > 0) then
			for i = 1, #echoes do
				local echo = echoes[i]
				if (!voidResponse[echo.id]) then continue end

				echo.inVoid = true
			end
		end

		local airResponse = net.ReadTable()

		-- Make echoes in the air fall to the ground
		if (table.Count(airResponse) > 0) then
			local enableAir = GetConVar("echoes_enableairechoes"):GetBool()

			for _, echo in pairs(echoes) do
				local airPos = airResponse[echo.id]
				if (!airPos or echo.airPos) then continue end

				echo.ogPos = echo.pos
				echo.airPos = airPos
				echo.pos = !enableAir and airPos or echo.pos
			end
		end
	end)
end
