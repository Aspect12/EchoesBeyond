
-- A simple changelog menu
local PANEL = {}
local vignette = Material("echoesbeyond/vignette.png")
local changelogID = "asdasd"

function PANEL:Init()
	if (IsValid(changeLog)) then
		changeLog:Remove()
	end

	changeLog = self

	self:SetSize(600, 300)
	self:Center()
	self:MakePopup()
	self:SetAlpha(0)

	self.startTime = SysTime()

	self:AlphaTo(255, 0.25)
	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetFont("DermaLarge")
	title:SetText("Welcome back!")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("Here's what is new since your last visit:")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	local changelogContainer = vgui.Create("DPanel", self)
	changelogContainer:SetSize(self:GetWide() - 40, self:GetTall() - 135)
	changelogContainer:CenterHorizontal()
	changelogContainer:SetY(85)
	changelogContainer.Paint = function(this, width, height)
		surface.SetDrawColor(30, 30, 30)
		surface.DrawRect(0, 0, width, height)
	end

	local changelog = vgui.Create("DTextEntry", changelogContainer)
	changelog:Dock(FILL)
	changelog:DockMargin(5, 5, 5, 5)
	changelog:SetMultiline(true)
	changelog:SetEditable(false)
	changelog.Paint = function(this, width, height)
		this:DrawTextEntryText(color_white, color_white, color_white)
	end

	changelog:SetText([[
		- Minor visual update to Personal Echoes menu.
	]])

	local close = vgui.Create("DButton", self)
	close:SetSize(self:GetWide() * 0.3, 30)
	close:SetText("Close")
	close:SetFont("CreditsText")
	close:SetColor(Color(175, 175, 175))
	close:CenterHorizontal()
	close:SetY(self:GetTall() - 40)
	close.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
	end
	close.DoClick = function()
		self:Close()

		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))
	end
end

function PANEL:Close()
	file.Write("echoesbeyond/changelogid.txt", changelogID)

	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_R and key != KEY_TAB) then return end

	self:Close()
end

function PANEL:Paint(width, height)
	Derma_DrawBackgroundBlur(self, self.startTime)

	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)
end

vgui.Register("echoChangelog", PANEL, "DPanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "changelog_OnPauseMenuShow", function()
	if (!IsValid(changeLog)) then return end

	changeLog:Close()

	return false
end)

hook.Add("InitPostEntity", "changelog_InitPostEntity", function()
	if (!file.Exists("echoesbeyond/readechoes.txt", "DATA")) then -- Don't show the changelog if the player is playing for the first time
		file.Write("echoesbeyond/changelogid.txt", changelogID)

		return
	end

	local oldID = file.Read("echoesbeyond/changelogid.txt", "DATA")
	if (oldID == changelogID) then return end -- Don't show the changelog if the player has already seen it

	vgui.Create("echoChangelog")
end)
