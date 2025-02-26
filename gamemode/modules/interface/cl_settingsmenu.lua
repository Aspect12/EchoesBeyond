
local vignette = Material("echoesbeyond/vignette.png", "smooth")

-- The settings menu
local function ToggleMusic(bEnabled)
	local music = GetConVar("echoes_music")

	if (bEnabled) then
		music:SetBool(true)
		PlayMusic()
	else
		music:SetBool(false)
		StopMusic()
	end
end

local function ToggleProfanity(bEnabled)
	local profanity = GetConVar("echoes_profanity")

	if (bEnabled) then
		profanity:SetBool(true)
	else
		profanity:SetBool(false)
	end
end

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

	local music = GetConVar("echoes_music")

	local musicCheckbox = vgui.Create("DCheckBoxLabel", self)
	musicCheckbox:SetText("Enable music")
	musicCheckbox:SetValue(music:GetBool())
	musicCheckbox:SizeToContents()
	musicCheckbox:SetPos(50, 100)
	musicCheckbox.OnChange = function(self, value)
		ToggleMusic(value)
	end

	local profanity = GetConVar("echoes_profanity")

	local profanityCheckbox = vgui.Create("DCheckBoxLabel", self)
	profanityCheckbox:SetText("Show offensive Echoes")
	profanityCheckbox:SetValue(profanity:GetBool())
	profanityCheckbox:SizeToContents()
	profanityCheckbox:SetPos(50, 125)
	profanityCheckbox.OnChange = function(self, value)
		ToggleProfanity(value)
	end

	local smoothView = GetConVar("echoes_smoothview")

	local smoothViewCheckbox = vgui.Create("DCheckBoxLabel", self)
	smoothViewCheckbox:SetText("Enable smooth view")
	smoothViewCheckbox:SetValue(smoothView:GetBool())
	smoothViewCheckbox:SizeToContents()
	smoothViewCheckbox:SetPos(50, 150)
	smoothViewCheckbox.OnChange = function(self, value)
		smoothView:SetBool(value)
	end

	local readEchoes = GetConVar("echoes_showread")

	local readEchoesCheckbox = vgui.Create("DCheckBoxLabel", self)
	readEchoesCheckbox:SetText("Show read Echoes")
	readEchoesCheckbox:SetValue(readEchoes:GetBool())
	readEchoesCheckbox:SizeToContents()
	readEchoesCheckbox:SetPos(50, 175)
	readEchoesCheckbox.OnChange = function(self, value)
		readEchoes:SetBool(value)
	end

	local dlights = GetConVar("echoes_dlights")

	local dlightsCheckbox = vgui.Create("DCheckBoxLabel", self)
	dlightsCheckbox:SetText("Enable dynamic lights")
	dlightsCheckbox:SetValue(dlights:GetBool())
	dlightsCheckbox:SizeToContents()
	dlightsCheckbox:SetPos(50, 200)
	dlightsCheckbox.OnChange = function(self, value)
		dlights:SetBool(value)
	end

	local windowFlash = GetConVar("echoes_windowflash")

	local windowFlashCheckbox = vgui.Create("DCheckBoxLabel", self)
	windowFlashCheckbox:SetText("Flash game window when a new Echo is created")
	windowFlashCheckbox:SetValue(windowFlash:GetBool())
	windowFlashCheckbox:SizeToContents()
	windowFlashCheckbox:SetPos(50, 225)
	windowFlashCheckbox.OnChange = function(self, value)
		windowFlash:SetBool(value)
	end

	local speed = GetConVar("echoes_speed")

	local speedSlider = vgui.Create("DNumSlider", self)
	speedSlider:SetText("Movement Speed")
	speedSlider:SetMin(1)
	speedSlider:SetMax(1000)
	speedSlider:SetDecimals(0)
	speedSlider:SetValue(speed:GetInt())
	speedSlider:SetWide(self:GetWide() - 100)
	speedSlider:SetPos(50, 250)
	speedSlider.OnValueChanged = function(self, value)
		speed:SetInt(value)
	end

	local renderDist = GetConVar("echoes_renderdist")

	local renderDistSlider = vgui.Create("DNumSlider", self)
	renderDistSlider:SetText("Render Distance")
	renderDistSlider:SetMin(10000)
	renderDistSlider:SetMax(100000000)
	renderDistSlider:SetDecimals(0)
	renderDistSlider:SetValue(renderDist:GetInt())
	renderDistSlider:SetWide(self:GetWide() - 100)
	renderDistSlider:SetPos(50, 275)
	renderDistSlider.OnValueChanged = function(self, value)
		renderDist:SetInt(value)
	end

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
