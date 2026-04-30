
-- The main menu
local echoMat = Material("echoesbeyond/echo_simple.png", "smooth")
local echoSimpleBlankMat = Material("echoesbeyond/echo_simple_blank.png", "smooth")
local echoBlankMat = Material("echoesbeyond/echo_blank.png", "smooth")
local echoDotSimpleMat = Material("echoesbeyond/echo_simple_dot_single.png", "smooth")
local echoDotSingleMat = Material("echoesbeyond/echo_dot_single.png", "smooth")
local mapMat = Material("echoesbeyond/map.png", "smooth")
local settingsMat = Material("echoesbeyond/settings.png", "smooth")
local vignette = Material("echoesbeyond/vignette.png", "smooth")
local creditsMat = Material("echoesbeyond/credits.png", "smooth")
local changelogMat = Material("echoesbeyond/changelog.png", "smooth")

-- Creates little 'bridges' between the panels
local function CreateBridge(side, buttonY, targetPanel)
	local bridge = vgui.Create("DPanel")

	bridge:SetParent(vgui.GetWorldPanel())
	bridge:SetPaintBackground(false)
	bridge:SetSize(10, 48)
	bridge.Paint = function(self, width, height)
		surface.SetDrawColor(25, 25, 25)
		surface.DrawRect(0, 0, width, height)
	end
	bridge.Think = function(self)
		if (!IsValid(mainMenu)) then self:Remove() return end

		local mx, my = mainMenu:GetPos()

		if (side == "left") then
			self:SetPos(mx - 10, my + buttonY)
		else
			self:SetPos(mx + mainMenu:GetWide(), my + buttonY)
		end

		if (!IsValid(targetPanel)) then return end

		self:SetAlpha(targetPanel:GetAlpha())
	end

	return bridge
end

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

	EchoSound("whoosh", nil, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Echoes Beyond")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("- A cinematic thought experiment -")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	local reloadBind = string.upper(input.LookupBinding("+reload") or "r")
	local createHint = vgui.Create("DLabel", self)
	createHint:SetText("Press '" .. reloadBind .. "' to write an echo.")
	createHint:SizeToContents()
	createHint:CenterHorizontal()
	createHint:SetY(75)

	local walkBind, useBind = string.upper(input.LookupBinding("+walk") or "alt"), string.upper(input.LookupBinding("+use") or "e")
	local translateHint = vgui.Create("DLabel", self)
	translateHint:SetText("Press '" .. walkBind .. "+" .. useBind .. "' to translate an echo.")
	translateHint:SizeToContents()
	translateHint:CenterHorizontal()
	translateHint:SetY(95)

	local mapOption = vgui.Create("DButton", self)
	mapOption:SetSize(48, 48)
	mapOption:SetPos(10, 10)
	mapOption:SetText("")
	mapOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or (self:IsHovered() or IsValid(mapMenu)) and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(mapMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	mapOption.DoClick = function()
		EchoSound("button_click")

		if (IsValid(personalEchoesMenu)) then personalEchoesMenu:Close(true) end

		if (IsValid(mapMenu)) then
			mapMenu:Close()
		else
			vgui.Create("echoMapMenu")
			local bridge = CreateBridge("left", 10, mapMenu)
			mapMenu.OnRemove = function() if (IsValid(bridge)) then bridge:Remove() end end
		end
	end

	local personalEchoes = vgui.Create("DButton", self)
	personalEchoes:SetSize(48, 48)
	personalEchoes:SetPos(10, 48 + 20)
	personalEchoes:SetText("")
	personalEchoes.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or (self:IsHovered() or IsValid(personalEchoesMenu)) and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(echoMat)
		surface.DrawTexturedRect(-7, -7, width + 14, height + 14)
	end
	personalEchoes.DoClick = function()
		EchoSound("button_click")

		if (IsValid(mapMenu)) then mapMenu:Close(true) end

		if (IsValid(personalEchoesMenu)) then
			personalEchoesMenu:Close()
		else
			vgui.Create("echoPersonalEchoesMenu")
			local bridge = CreateBridge("left", 68, personalEchoesMenu)
			personalEchoesMenu.OnRemove = function() if (IsValid(bridge)) then bridge:Remove() end end
		end
	end

	local settingsOption = vgui.Create("DButton", self)
	settingsOption:SetSize(48, 48)
	settingsOption:SetPos(self:GetWide() - 48 - 10, 10)
	settingsOption:SetText("")
	settingsOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or (self:IsHovered() or IsValid(settingsMenu)) and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(settingsMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	settingsOption.DoClick = function()
		EchoSound("button_click")

		if (IsValid(reportMenu)) then reportMenu:Close(true) end
		if (IsValid(creditsMenu)) then creditsMenu:Close(true) end

		if (IsValid(settingsMenu)) then
			settingsMenu:Close()
		else
			vgui.Create("echoSettingsMenu")
			local bridge = CreateBridge("right", 10, settingsMenu)
			settingsMenu.OnRemove = function() if (IsValid(bridge)) then bridge:Remove() end end
		end
	end

	local creditsOption = vgui.Create("DButton", self)
	creditsOption:SetSize(48, 48)
	creditsOption:SetPos(self:GetWide() - 48 - 10, self:GetTall() - 48 - 10)
	creditsOption:SetText("")
	creditsOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or (self:IsHovered() or IsValid(creditsMenu)) and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(creditsMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	creditsOption.DoClick = function()
		EchoSound("button_click")

		if (IsValid(settingsMenu)) then settingsMenu:Close(true) end
		if (IsValid(reportMenu)) then reportMenu:Close(true) end

		if (IsValid(creditsMenu)) then
			creditsMenu:Close()
		else
			vgui.Create("echoCreditsMenu")
			local bridge = CreateBridge("right", mainMenu:GetTall() - 48 - 10, creditsMenu)
			creditsMenu.OnRemove = function() if (IsValid(bridge)) then bridge:Remove() end end
		end
	end

	local changelogOption = vgui.Create("DButton", self)
	changelogOption:SetSize(48, 48)
	changelogOption:SetPos(10, self:GetTall() - 48 - 10)
	changelogOption:SetText("")
	changelogOption.Paint = function(self, width, height)
		surface.SetDrawColor(self:IsDown() and Color(100, 100, 100) or (self:IsHovered() or IsValid(changeLog)) and Color(75, 75, 75) or Color(50, 50, 50))
		surface.SetMaterial(changelogMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	changelogOption.DoClick = function()
		EchoSound("button_click")

		vgui.Create("echoChangelog")
	end

	local maps = {}
	self.ownMapCount = 0

	for i = 1, #writtenEchoes do
		local map = writtenEchoes[i].map
		if (maps[map]) then continue end

		maps[map] = true
	end

	self.ownMapCount = table.Count(maps)
	self.ownReadCount = #file.ReadOrCreate("echoesbeyond/readechoes.txt")

	local panelW, panelH = self:GetSize()
	local echoSize = panelH / 1.5
	local hoverZone = vgui.Create("DPanel", self)

	hoverZone:SetSize(echoSize, echoSize)
	hoverZone:SetPos(panelW / 2 - echoSize / 2, panelH / 2 - echoSize / 2)
	hoverZone:SetPaintBackground(false)
	hoverZone.OnCursorEntered = function() self.echoHovered = true EchoSound("echo_activate", 60, 0.1) end
	hoverZone.OnCursorExited = function() self.echoHovered = false EchoSound("echo_activate", 50, 0.1) end
	hoverZone.OnMousePressed = function() self.clickTime = CurTime() EchoSound("echo_create", math.random(75, 125), 0.5) end

	if (endPartyEnabled) then
		local endParty = vgui.Create("DButton", self)
		endParty:SetSize(self:GetWide() * 0.25, 30)
		endParty:SetText("End Party Mode")
		endParty:SetFont("CreditsText")
		endParty:SetColor(Color(175, 175, 175))
		endParty:Center()
		endParty.Paint = function(this, width, height)
			surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
			surface.DrawRect(0, 0, width, height)
		end
		endParty.DoClick = function(this)
			this:Remove()
			timer.Adjust("echoesParty", 0)

			EchoNotify("Party mode disabled.")
		end
	end
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

	local frameTime = FrameTime()
	local hoverLerp = Lerp(frameTime * 4, self.hoverLerp or 0, self.echoHovered and 1 or 0)
	self.hoverLerp = hoverLerp

	local clickPulse = math.max(0, 1 - (CurTime() - (self.clickTime or -math.huge)) * 4)

	self.animTime = (self.animTime or 0) + frameTime * 1.5 * hoverLerp
	local curTimeSpeed = self.animTime

	local breatheLayer = math.sin(curTimeSpeed) * hoverLerp

	local dotSize = height / 1.5
	local dotHSpacing = dotSize * (280 / 1920)
	local dotBobAmp = dotSize * (50 / 1920)
	local dotBaseY = height / 2 + 5 * breatheLayer

	surface.SetDrawColor(255, 255, 255, math.floor(5 * (1 - hoverLerp) + 3 * clickPulse))
	surface.SetMaterial(echoSimpleBlankMat)
	surface.DrawTexturedRectRotated(width / 2, dotBaseY, dotSize, dotSize, 0)

	surface.SetDrawColor(255, 255, 255, math.floor(10 * hoverLerp + 3 * clickPulse))
	surface.SetMaterial(echoBlankMat)
	surface.DrawTexturedRectRotated(width / 2, dotBaseY, dotSize, dotSize, 0)

	surface.SetDrawColor(25, 25, 25, math.floor(255 * (1 - hoverLerp)))
	surface.SetMaterial(echoDotSimpleMat)
	surface.DrawTexturedRectRotated(width / 2 - dotHSpacing, dotBaseY + dotBobAmp * math.sin(curTimeSpeed) * hoverLerp, dotSize, dotSize, 0)
	surface.DrawTexturedRectRotated(width / 2, dotBaseY + dotBobAmp * math.sin(curTimeSpeed + 20) * hoverLerp, dotSize, dotSize, 0)
	surface.DrawTexturedRectRotated(width / 2 + dotHSpacing, dotBaseY + dotBobAmp * math.sin(curTimeSpeed + 40) * hoverLerp, dotSize, dotSize, 0)

	surface.SetDrawColor(25, 25, 25, math.floor(255 * hoverLerp))
	surface.SetMaterial(echoDotSingleMat)
	surface.DrawTexturedRectRotated(width / 2 - dotHSpacing, dotBaseY + dotBobAmp * math.sin(curTimeSpeed) * hoverLerp, dotSize, dotSize, 0)
	surface.DrawTexturedRectRotated(width / 2, dotBaseY + dotBobAmp * math.sin(curTimeSpeed + 20) * hoverLerp, dotSize, dotSize, 0)
	surface.DrawTexturedRectRotated(width / 2 + dotHSpacing, dotBaseY + dotBobAmp * math.sin(curTimeSpeed + 40) * hoverLerp, dotSize, dotSize, 0)

	if (endPartyEnabled) then
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, width, height)
	end

	local echoCount = #echoes
	local writeRep = math.Round((#writtenEchoes / globalEchoCount) * 100, 2)
	local readPercent = globalEchoCount > 0 and math.Round((self.ownReadCount / globalEchoCount) * 100, 2) or 0

	draw.SimpleText("There " .. (echoCount == 1 and "is" or "are") .. " currently " .. echoCount .. " echo" .. (echoCount == 1 and "" or "es") .. " on this map. You have read " .. readEchoCount .. " of them.", "DermaDefault", width / 2, height - 70, self.colorStats1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("You have written " .. #writtenEchoes .. " echo" .. (#writtenEchoes == 1 and "" or "es") .. " across " .. self.ownMapCount .. (self.ownMapCount == 1 and " map. " or " different maps. " .. "You represent " .. writeRep .. "% of all echoes."), "DermaDefault", width / 2, height - 50, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("There are currently " .. globalEchoCount .. " echoes across " .. mapCount .. " maps from " .. userCount .. " users. You have read " .. self.ownReadCount .. " (" .. readPercent .. "%) of them.", "DermaDefault", width / 2, height - 30, self.colorStats3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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

	if (IsValid(creditsMenu)) then
		creditsMenu:Close(true)
	end

	if (IsValid(personalEchoesMenu)) then
		personalEchoesMenu:Close(true)
	end

	EchoSound("whoosh", 90, 0.75)

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
end

vgui.Register("echoMainMenu", PANEL, "EditablePanel")

hook.Add("ScoreboardShow", "mainmenu_ScoreboardShow", function()
	vgui.Create("echoMainMenu")

	return false -- Hide the default scoreboard
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
