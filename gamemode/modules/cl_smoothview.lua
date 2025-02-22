
-- Smoothens the player's view
local curView

hook.Add("CalcView", "smoothview_CalcView", function(client, origin, angles, fov, zNear, zFar)
	curView = curView and LerpAngle(math.Clamp(FrameTime() * 10, 0, 1), curView, angles) or angles

	return {angles = curView}
end)
