
-- Hide HUD
hook.Add("HUDShouldDraw", "interface_HUDShouldDraw", function(name)
	return name == "CHudGMod"
end)

-- Block chat binds
local binds = {
	["messagemode"] = true,
	["messagemode2"] = true
}

hook.Add("PlayerBindPress", "interface_PlayerBindPress", function(client, bind, pressed)
	if (!binds[bind]) then return end

	return true
end)
