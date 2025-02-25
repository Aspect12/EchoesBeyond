
local echoMat = Material("echoesbeyond/echo_simple.png", "smooth")
local mapMat = Material("echoesbeyond/map.png", "smooth")
local settingsMat = Material("echoesbeyond/settings.png", "smooth")
local reportMat = Material("echoesbeyond/report.png", "smooth")
local vignette = Material("echoesbeyond/vignette.png", "smooth")

local PANEL = {}

function PANEL:Init()
	if (IsValid(mainMenu)) then
		mainMenu:Remove()
	end

	mainMenu = self

	FetchStats()
	timer.Create("echoesFetchStats", 1, 0, FetchStats)

	self.colorStats1, self.colorStats3 = Color(200, 200, 200), Color(200, 200, 200)

	self:SetSize(ScrW() / 2.5, ScrH() / 2)
	self:Center()
	self:MakePopup()
	self:SetAlpha(0)
	self:AlphaTo(255, 0.5)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Echoes Beyond")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	-- TODO: Make this a wave
	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("- A cinematic thought experiment -")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	local mapOption = vgui.Create("DButton", self)
	mapOption:SetSize(48, 48)
	mapOption:SetPos(10, 10)
	mapOption:SetText("")
	mapOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or self:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(mapMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	mapOption.DoClick = function()
		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))

		if (IsValid(mapMenu)) then
			mapMenu:Close()
		else
			vgui.Create("echoMapMenu")
		end
	end

	local settingsOption = vgui.Create("DButton", self)
	settingsOption:SetSize(48, 48)
	settingsOption:SetPos(self:GetWide() - 48 - 10, 10)
	settingsOption:SetText("")
	settingsOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or self:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(settingsMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	settingsOption.DoClick = function()
		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))

		if (IsValid(reportMenu)) then reportMenu:Close() end

		if (IsValid(settingsMenu)) then
			settingsMenu:Close()
		else
			vgui.Create("echoSettingsMenu")
		end
	end

	local reportOption = vgui.Create("DButton", self)
	reportOption:SetSize(48, 48)
	reportOption:SetPos(self:GetWide() - 48 - 10, 48 + 20)
	reportOption:SetText("")
	reportOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or self:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(reportMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	reportOption.DoClick = function()
		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))

		if (IsValid(settingsMenu)) then settingsMenu:Close() end

		if (IsValid(reportMenu)) then
			reportMenu:Close()
		else
			vgui.Create("echoReportMenu")
		end
	end

	local maps = {}
	self.ownMapCount = 0

	for i = 1, #writtenEchoes do
		local map = writtenEchoes[i].map
		if (maps[map]) then continue end

		maps[map] = true
	end

	self.ownMapCount = table.Count(maps)
end

function PANEL:UpdateStats(newUserCount, newEchoCount, newMapCount, newMaps)
	if (newUserCount != userCount or newMapCount != mapCount or newEchoCount != globalEchoCount) then
		self.colorStats3 = Color(50, 150, 255)
	end

	if (!newUserCount and newEchoCount != #echoes) then
		self.colorStats1 = Color(50, 150, 255)
	end

	if (!IsValid(mapMenu) or !newMaps) then return end

	mapMenu:UpdateMaps(newMaps)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)

	local breatheLayer = math.sin(CurTime() * 1.5)

	surface.SetDrawColor(255, 255, 255, 5)
	surface.SetMaterial(echoMat)
	surface.DrawTexturedRectRotated(width / 2, height / 2 + 5 * breatheLayer, height / 1.5, height / 1.5, 0)

	local echoCount = #echoes
	local frameTime = FrameTime()

	draw.SimpleText("There " .. (echoCount == 1 and "is" or "are") .. " currently " .. echoCount .. " echo" .. (echoCount == 1 and "" or "es") .. " on this map. You have read " .. readEchoCount .. " of them.", "DermaDefault", width / 2, height - 70, self.colorStats1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("You have written " .. #writtenEchoes .. " echo" .. (#writtenEchoes == 1 and "" or "es") .. " across " .. self.ownMapCount .. (self.ownMapCount == 1 and " map." or " different maps."), "DermaDefault", width / 2, height - 50, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("There are currently " .. globalEchoCount .. " total echoes across " .. mapCount .. " different maps from " .. userCount .. " different users.", "DermaDefault", width / 2, height - 30, self.colorStats3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	self.colorStats1, self.colorStats3 = LerpColor(frameTime, self.colorStats1, Color(200, 200, 200)), LerpColor(frameTime, self.colorStats3, Color(200, 200, 200))
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_TAB) then return end

	self:Close()
end

function PANEL:Close()
	timer.Remove("echoesFetchStats")

	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)

	if (IsValid(mapMenu)) then
		mapMenu:Close(true)
	end

	if (IsValid(settingsMenu)) then
		settingsMenu:Close(true)
	end

	if (IsValid(reportMenu)) then
		reportMenu:Close(true)
	end

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
end

vgui.Register("echoMainMenu", PANEL, "EditablePanel")

-- The main menu
hook.Add("ScoreboardShow", "mainmenu_ScoreboardShow", function()
	vgui.Create("echoMainMenu")

	return false
end)

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "mainmenu_OnPauseMenuShow", function()
	if (!IsValid(mainMenu)) then return end

	mainMenu:Close()

	return false
end)

hook.Add("HUDPaint", "mainmenu_HUDPaint", function()
	if (!IsValid(mainMenu)) then return end
	local alpha = mainMenu:GetAlpha()

	surface.SetDrawColor(25, 25, 25, 200 * (alpha / 255))
	surface.DrawRect(0, 0, ScrW(), ScrH())
end)
