
-- Gets the number of map-created dynamic lights
dLightCount = dLightCount or 0

CreateClientConVar("echoes_dlights", "1")

hook.Add("InitPostEntity", "dlights_InitPostEntity", function()
	dLightCount = #ents.FindByClass("light_dynamic")
end)
