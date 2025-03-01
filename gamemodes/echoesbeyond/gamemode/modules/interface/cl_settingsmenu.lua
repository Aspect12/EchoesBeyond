
-- The settings menu
local vignette = Material("echoesbeyond/vignette.png", "smooth")

local PANEL = {}
local y = 100

local gabenSounds = {
	"/gaben/al_intro",
	"/gaben/hl2_intro",
	"/gaben/l4d2_intro",
	"/gaben/l4d_intro",
	"/gaben/lc_intro",
	"/gaben/p2_intro"
}

local function CreateCheckbox(text, convar, callback)
	local checkbox = vgui.Create("DCheckBoxLabel", settingsMenu)
	checkbox:SetText(text)
	checkbox:SetValue(convar:GetBool())
	checkbox:SizeToContents()
	checkbox:SetPos(50, y)
	checkbox.OnChange = function(self, value)
		convar:SetBool(value)

		if (callback) then
			callback(value)
		end
	end

	y = y + 25
end

local function CreateSlider(text, convar, min, max, decimals)
	local slider = vgui.Create("DNumSlider", settingsMenu)
	slider:SetText(text)
	slider:SetMin(min)
	slider:SetMax(max)
	slider:SetDecimals(decimals)
	slider:SetValue(convar:GetInt())
	slider:SetWide(settingsMenu:GetWide() - 100)
	slider:SetPos(50, y)
	slider.OnValueChanged = function(self, value)
		convar:SetInt(value)
	end

	y = y + 25
end

function PANEL:Init()
	if (IsValid(settingsMenu)) then
		settingsMenu:Remove()
	end

	y = 100

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

	CreateCheckbox("Enable music", GetConVar("echoes_music"))
	CreateCheckbox("Show offensive Echoes", GetConVar("echoes_profanity"))
	CreateCheckbox("Enable smooth view", GetConVar("echoes_smoothview"))
	CreateCheckbox("Show read Echoes", GetConVar("echoes_showread"))
	CreateCheckbox("Enable dynamic lights", GetConVar("echoes_dlights"))
	CreateCheckbox("Flash game window when a new Echo is created", GetConVar("echoes_windowflash"))
	CreateCheckbox("Disable Echo 'read' system", GetConVar("echoes_disablereadsys"))
	CreateCheckbox("Disable author signing", GetConVar("echoes_disablesigning"))
	CreateCheckbox("Enable GabeN mode", GetConVar("echoes_gabenmode"), function(value)
		if (!value) then return end

		EchoSound(table.Random(gabenSounds), nil, 0.75)
	end)

	CreateSlider("Movement Speed", GetConVar("echoes_speed"), 1, 1000, 0)
	CreateSlider("Render Distance", GetConVar("echoes_renderdist"), 10000, 100000000, 0)

	local deleteAll = vgui.Create("DButton", self)
	deleteAll:SetSize(self:GetWide() * 0.5, 30)
	deleteAll:SetText("Delete all data")
	deleteAll:SetFont("CreditsText")
	deleteAll:SetColor(Color(175, 175, 175))
	deleteAll:CenterHorizontal()
	deleteAll:SetY(self:GetTall() - 50)
	deleteAll.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
	end
	deleteAll.DoClick = function()
		EchoesConfirm("Delete all data", "This will delete all of your data from Echoes Beyond, including all Echoes. Are you sure?", function()
			http.Fetch("https://resonance.flatgrass.net/nuke", function(body, _, _, code)
				if (code != 200) then
					EchoNotify("RESONANCE ERROR: " .. string.sub(body, 1, -2))

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
	EchoSound("whoosh", 90, 0.75)
end

vgui.Register("echoSettingsMenu", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "settingsmenu_OnPauseMenuShow", function()
	if (!IsValid(settingsMenu)) then return end

	settingsMenu:Close()

	return false
end)
