
local vignette = Material("echoesbeyond/vignette.png", "smooth")
local settingsMat = Material("echoesbeyond/settings.png", "smooth")

local PANEL = {}
local lastOpenedTab = 1

local tabNames = {"General", "Gameplay", "Visual", "Advanced"}
local tabButtons = {}
local tabPanels = {}
local tabY = {}
local tabStartY = 90
local tabHeight = 30

local function CreateCheckbox(tab, text, convar)
	local checkbox = vgui.Create("DCheckBoxLabel", tabPanels[tab])
	checkbox:SetText(text)
	checkbox:SetValue(convar:GetBool())
	checkbox:SizeToContents()
	checkbox:SetPos(50, tabY[tab])
	checkbox:SetTextColor(Color(200, 200, 200))
	checkbox.OnChange = function(self, value)
		EchoSound("button_click")
		convar:SetBool(value)
	end
	checkbox.Button.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
		surface.SetDrawColor(100, 100, 100)
		surface.DrawOutlinedRect(0, 0, width, height)

		if (!this:GetChecked()) then return end

		surface.SetDrawColor(220, 220, 220)
		surface.DrawLine(3, height / 2, width * 0.4, height - 4)
		surface.DrawLine(width * 0.4, height - 4, width - 3, 3)
	end

	tabY[tab] = tabY[tab] + 25
end

local timeUnits = {
	{"month", 2592000},
	{"week", 604800},
	{"day", 86400},
	{"hour", 3600},
	{"minute", 60},
	{"second", 1}
}

local function FormatTimeAgo(value, min, max)
	if (value >= max - echoTimeTolerance) then return "Now (Live)" end
	if (value <= min + echoTimeTolerance) then return "First Echo Time" end

	local diff = math.max(os.time() - value, 1)

	for i = 1, #timeUnits do
		local name, seconds = timeUnits[i][1], timeUnits[i][2]
		if (diff < seconds and i != #timeUnits) then continue end

		local amount = math.max(math.floor(diff / seconds), 1)

		return amount .. " " .. name .. (amount == 1 and "" or "s") .. " ago"
	end
end

local function CreateSlider(tab, text, convar, min, max, decimals, formatter)
	local parent = tabPanels[tab]
	local slider = vgui.Create("DNumSlider", parent)
	slider:SetText(text)
	slider:SetMin(min)
	slider:SetMax(max)
	slider:SetDecimals(decimals)

	if (formatter) then
		local valueChanged = slider.ValueChanged

		slider.TextArea:SetEditable(false)
		slider.TextArea:SetWide(80)
		slider.TextArea:SetCursor("arrow")

		slider.ValueChanged = function(self, value)
			valueChanged(self, value)

			self.TextArea:SetText(formatter(math.Clamp(tonumber(value) or min, min, max), min, max))
		end
	end

	slider:SetValue(convar:GetInt())
	slider:SetWide(parent:GetWide() - 100)
	slider:SetPos(50, tabY[tab])
	slider.OnValueChanged = function(_, value)
		convar:SetInt(math.Round(value))
	end

	tabY[tab] = tabY[tab] + slider:GetTall() + 5
end

local function SwitchToTab(index)
	lastOpenedTab = index

	for i, panel in ipairs(tabPanels) do
		panel:SetVisible(i == index)
	end

	for i, button in ipairs(tabButtons) do
		button.isActive = i == index
	end
end

function PANEL:Init()
	if (IsValid(settingsMenu)) then
		settingsMenu:Remove()
	end

	settingsMenu = self

	self:SetSize(ScrW() / 4, ScrH() / 1.5)
	self:Center()
	self:SetX(mainMenu:GetX() + mainMenu:GetWide() + 10)
	self:MakePopup()
	self:SetAlpha(0)

	self:AlphaTo(255, 0.5)
	EchoSound("whoosh", nil, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Settings")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("Configure your experience here.")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	tabButtons = {}
	tabPanels = {}
	tabY = {}

	for i = 1, #tabNames do
		local content = vgui.Create("DPanel", self)
		content:SetPos(0, tabStartY + tabHeight)
		content:SetSize(self:GetWide(), self:GetTall() - (tabStartY + tabHeight))
		content:SetPaintBackground(false)

		tabPanels[i] = content
		tabY[i] = 20
	end

	local totalTabsWidth = 0
	local buttonSpacing = 2

	for i, name in ipairs(tabNames) do
		local button = vgui.Create("DButton", self)
		button:SetText(name)
		button:SetFont("TargetID")
		button:SizeToContentsX(15)
		button:SetColor(Color(175, 175, 175))
		button:SetTall(tabHeight)
		button.isActive = false
		button.Paint = function(this, width, height)
			surface.SetDrawColor((this.isActive or this:IsDown()) and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
			surface.DrawRect(0, 0, width, height)
		end
		button.DoClick = function()
			SwitchToTab(i)
			EchoSound("button_click")
		end

		tabButtons[i] = button
		totalTabsWidth = totalTabsWidth + button:GetWide()
	end

	totalTabsWidth = totalTabsWidth + (#tabButtons - 1) * buttonSpacing

	local currentX = (self:GetWide() - totalTabsWidth) / 2
	for _, button in ipairs(tabButtons) do
		button:SetPos(currentX, tabStartY)
		currentX = currentX + button:GetWide() + buttonSpacing
	end

	CreateCheckbox(1, "Enable music", GetConVar("echoes_music"))
	CreateCheckbox(1, "Show read Echoes", GetConVar("echoes_showread"))
	CreateCheckbox(1, "Show offensive Echoes", GetConVar("echoes_profanity"))
	CreateCheckbox(1, "Flash game when a new Echo is made", GetConVar("echoes_windowflash"))

	CreateCheckbox(2, "Enable Echo 'read' system", GetConVar("echoes_readsys"))
	CreateCheckbox(2, "Enable GabeN mode", GetConVar("echoes_gabenmode"))
	CreateCheckbox(2, "Enable void Echoes", GetConVar("echoes_enablevoidechoes"))
	CreateCheckbox(2, "Enable floating Echoes", GetConVar("echoes_enablefloatingechoes"))
	CreateSlider(2, "Movement Speed", GetConVar("echoes_speed"), 1, 1000, 0)

	CreateCheckbox(3, "Enable smooth view", GetConVar("echoes_smoothview"))
	CreateCheckbox(3, "Enable dynamic lights", GetConVar("echoes_dlights"))
	CreateCheckbox(3, "Hide author signatures", GetConVar("echoes_disablesigning"))
	CreateSlider(3, "Render Distance", GetConVar("echoes_renderdist"), 10000, 100000000, 0)

	-- While viewing the present, keep the slider pinned to the current time
	echoTimeMax = os.time()

	local timeConvar = GetConVar("echoes_timetravel_time")

	if (echoTimeLive) then
		timeConvar:SetInt(echoTimeMax)
	end

	CreateSlider(4, "Echo Time Period", timeConvar, echoTimeMin, echoTimeMax, 0, FormatTimeAgo)

	do
		local content = tabPanels[4]

		local deleteAll = vgui.Create("DButton", content)
		deleteAll:SetSize(content:GetWide() * 0.5, 30)
		deleteAll:SetText("Delete all data")
		deleteAll:SetFont("CreditsText")
		deleteAll:SetColor(Color(175, 175, 175))
		deleteAll:CenterHorizontal()
		deleteAll:SetY(content:GetTall() - 70)
		deleteAll.Paint = function(this, width, height)
			surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
			surface.DrawRect(0, 0, width, height)
		end
		deleteAll.DoClick = function()
			EchoesConfirm("Delete all data", "This will delete all of your data, per the EU's GDPR 'Right to Erasure'. This action is irreversible. Are you sure?", function()
				http.Fetch("https://resonance.flatgrass.net/nuke", function(body, _, _, code)
					if (code != 200) then
						if (code == 401) then
							EchoNotify("Your authentication token has expired. Please log in again.")

							authToken = nil
						else
							EchoNotify("RESONANCE ERROR: " .. string.sub(body, 1, -2))
						end

						return
					end

					mainMenu:Close()

					file.Delete("echoesbeyond/readechoes.txt")
					file.Delete("echoesbeyond/authtoken.txt")
					authToken = nil
					writtenEchoes = {}
					readEchoCount = 0

					local newEchoes = {}

					for i = 1, #echoes do
						local echo = echoes[i]
						if (echo.isOwner) then continue end

						newEchoes[#newEchoes + 1] = echo
					end

					echoes = newEchoes

					EchoNotify("All data has been deleted.")

					EchoSound("button_click")
				end, function(error)
					EchoNotify(error)
				end, {authorization = authToken})
			end)

			EchoSound("button_click")
		end
	end

	SwitchToTab(lastOpenedTab)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)
end

function PANEL:PaintOver(width, height)
	local size = math.min(width / 2, height / 2)
	local breatheLayer = math.sin(CurTime() * 1.5)

	surface.SetDrawColor(255, 255, 255, 1)
	surface.SetMaterial(settingsMat)
	surface.DrawTexturedRectRotated(width / 2, height / 2 + 5 * breatheLayer, size, size, 0)
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_TAB) then return end

	self:Close()
end

function PANEL:Close(bNoSound)
	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)

	if (bNoSound) then return end
	EchoSound("whoosh", 90, 0.75)
end

vgui.Register("echoSettingsMenu", PANEL, "EditablePanel")

hook.Add("OnPauseMenuShow", "settingsmenu_OnPauseMenuShow", function()
	if (!IsValid(settingsMenu)) then return end

	settingsMenu:Close()

	return false
end)
