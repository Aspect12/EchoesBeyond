
local vignette = Material("echoesbeyond/vignette.png", "smooth")

-- The map menu
local PANEL = {}

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
	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

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

	local music = GetConVar("echoes_music")

	local musicCheckbox = vgui.Create("DCheckBoxLabel", self)
	musicCheckbox:SetText("Enable Music")
	musicCheckbox:SetValue(music:GetBool())
	musicCheckbox:SizeToContents()
	musicCheckbox:SetPos(50, 100)
	musicCheckbox.OnChange = function(self, value)
		music:SetBool(value)
	end

	local profanity = GetConVar("echoes_profanity")

	local profanityCheckbox = vgui.Create("DCheckBoxLabel", self)
	profanityCheckbox:SetText("Show Offensive Echoes")
	profanityCheckbox:SetValue(profanity:GetBool())
	profanityCheckbox:SizeToContents()
	profanityCheckbox:SetPos(50, 125)
	profanityCheckbox.OnChange = function(self, value)
		profanity:SetBool(value)
	end

	local smoothView = GetConVar("echoes_smoothview")

	local smoothViewCheckbox = vgui.Create("DCheckBoxLabel", self)
	smoothViewCheckbox:SetText("Enable Smooth View")
	smoothViewCheckbox:SetValue(smoothView:GetBool())
	smoothViewCheckbox:SizeToContents()
	smoothViewCheckbox:SetPos(50, 150)
	smoothViewCheckbox.OnChange = function(self, value)
		smoothView:SetBool(value)
	end

	local speed = GetConVar("echoes_speed")

	local speedSlider = vgui.Create("DNumSlider", self)
	speedSlider:SetText("Movement Speed")
	speedSlider:SetMin(1)
	speedSlider:SetMax(1000)
	speedSlider:SetDecimals(0)
	speedSlider:SetValue(speed:GetInt())
	speedSlider:SetWide(self:GetWide() - 100)
	speedSlider:SetPos(50, 175)
	speedSlider.OnValueChanged = function(self, value)
		speed:SetInt(value)
	end
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)
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
	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)
end

vgui.Register("echoSettingsMenu", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "settingsmenu_OnPauseMenuShow", function()
	if (!IsValid(settingsMenu)) then return end

	settingsMenu:Close()

	return false
end)
