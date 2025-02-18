
include("shared.lua")

-- Hide HUD
function GM:HUDShouldDraw(name)
	return name == "CHudGMod"
end

-- Smooth View
local curView

function GM:CalcView(client, origin, angles, fov, zNear, zFar)
	curView = curView and LerpAngle(math.Clamp(FrameTime() * 5, 0, 1), curView, angles) or angles

	return {
		angles = curView
	}
end

-- Don't render other players
function GM:PrePlayerDraw(client, flags)
	return true
end

net.Receive("CreateNote", function()
	local position = net.ReadVector()

	notes[#notes + 1] = {
		pos = position,
		text = ""
	}
end)

-- Render notes
local noteMat = Material("echoesbeyond/note.png", "mips")

-- turn to 3d2d
function GM:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	for k, v in ipairs(notes) do
		local position = v.pos:ToScreen()
		local angle = (LocalPlayer():EyePos() - v.pos):Angle()
		angle:RotateAroundAxis(angle:Forward(), 90)
		angle:RotateAroundAxis(angle:Right(), 90)

		cam.Start3D2D(v.pos, -angle, 0.1)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(noteMat)
			surface.DrawTexturedRect(-128, -128, 256, 256)

			draw.SimpleText("shoii", "DebugFixed", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

-- Fetch notes on join
function GM:InitPostEntity()
	net.Start("FetchNotes")
	net.SendToServer()
end

net.Receive("FetchNotes", function()
	notes = net.ReadTable()
end)
