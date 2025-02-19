
-- Generic player setup
if (SERVER) then
	-- Set player attributes
	function GM:PlayerSpawn(client)
		client:SetGravity(0.85)
		client:SetWalkSpeed(100)
		client:SetRunSpeed(client:GetWalkSpeed() * 1.5)
		client:GodEnable()
	end

	-- Prevent suicide
	function GM:CanPlayerSuicide(client)
		return false
	end
else
	-- Don't render other players
	function GM:PrePlayerDraw(client, flags)
		return true
	end
end
