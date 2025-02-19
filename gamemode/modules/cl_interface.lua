
-- Hide HUD
function GM:HUDShouldDraw(name)
	return name == "CHudGMod"
end

-- Block chat binds
local binds = {
	["messagemode"] = true,
	["messagemode2"] = true
}

function GM:PlayerBindPress(client, bind)
	if (!binds[bind]) then return end

	return true
end
