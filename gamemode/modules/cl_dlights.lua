
-- Gets the number of map-created dynamic lights
dLightCount = dLightCount or 0

hook.Add("InitPostEntity", "dlights_InitPostEntity", function()
	dLightCount = #ents.FindByClass("light_dynamic")
end)
