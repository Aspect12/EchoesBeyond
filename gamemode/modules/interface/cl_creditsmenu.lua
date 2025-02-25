
local vignette = Material("echoesbeyond/vignette.png", "smooth")
local flatgrass, fgWidth, fgHeight = Material("echoesbeyond/flatgrass.png", "smooth"), 1000, 373

local PANEL = {}

function PANEL:Init()
	if (IsValid(creditsMenu)) then
		creditsMenu:Remove()
	end

	creditsMenu = self

	self:SetSize(ScrW() / 4, ScrH() / 1.5)
	self:Center()
	self:SetX(mainMenu:GetX() + mainMenu:GetWide() + 10)
	self:MakePopup()
	self:SetAlpha(0)

	self:AlphaTo(255, 0.5)
	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Credits")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local remedy = vgui.Create("DLabel", self)
	remedy:SetText("Max Payne 1 (Remedy)")
	remedy:SizeToContents()
	remedy:SetPos(20, 80)

	local remedy2 = vgui.Create("DLabel", self)
	remedy2:SetText("Notification Sound")
	remedy2:SizeToContents()
	remedy2:SetPos(self:GetWide() - 20 - remedy2:GetWide(), 80)

	local L7D = vgui.Create("DLabel", self)
	L7D:SetText("Catherine (L7D)")
	L7D:SizeToContents()
	L7D:SetPos(20, 100)

	local L7D2 = vgui.Create("DLabel", self)
	L7D2:SetText("Menu Movement Sound")
	L7D2:SizeToContents()
	L7D2:SetPos(self:GetWide() - 20 - L7D2:GetWide(), 100)

	local sony = vgui.Create("DLabel", self)
	sony:SetText("PlayStation 2 (Sony Computer Entertainment)")
	sony:SizeToContents()
	sony:SetPos(20, 120)

	local sony2 = vgui.Create("DLabel", self)
	sony2:SetText("Echo Sounds")
	sony2:SizeToContents()
	sony2:SetPos(self:GetWide() - 20 - sony2:GetWide(), 120)

	local exbleative = vgui.Create("DLabel", self)
	exbleative:SetText("Exo One (Exbleative)")
	exbleative:SizeToContents()
	exbleative:SetPos(20, 140)

	local exbleative2 = vgui.Create("DLabel", self)
	exbleative2:SetText("Music")
	exbleative2:SizeToContents()
	exbleative2:SetPos(self:GetWide() - 20 - exbleative2:GetWide(), 140)

	local cloudSixteen = vgui.Create("DLabel", self)
	cloudSixteen:SetText("Clockwork (CloudSixteen)")
	cloudSixteen:SizeToContents()
	cloudSixteen:SetPos(20, 160)

	local cloudSixteen2 = vgui.Create("DLabel", self)
	cloudSixteen2:SetText("Vignette Texture")
	cloudSixteen2:SizeToContents()
	cloudSixteen2:SetPos(self:GetWide() - 20 - cloudSixteen2:GetWide(), 160)

	local aspect = vgui.Create("DLabel", self)
	aspect:SetText("Aspect™")
	aspect:SizeToContents()
	aspect:SetPos(20, 180)

	local aspect2 = vgui.Create("DLabel", self)
	aspect2:SetText("Clientside Development")
	aspect2:SizeToContents()
	aspect2:SetPos(self:GetWide() - 20 - aspect2:GetWide(), 180)

	local friends = vgui.Create("DLabel", self)
	friends:SetText("Friends")
	friends:SizeToContents()
	friends:SetPos(20, 200)

	local friends2 = vgui.Create("DLabel", self)
	friends2:SetText("Feedback, ideas, support, and testing")
	friends2:SizeToContents()
	friends2:SetPos(self:GetWide() - 20 - friends2:GetWide(), 200)

	local badActors = vgui.Create("DLabel", self)
	badActors:SetText("Bad Actors")
	badActors:SizeToContents()
	badActors:SetPos(20, 220)

	local badActors2 = vgui.Create("DLabel", self)
	badActors2:SetText("Valuable web security experience")
	badActors2:SizeToContents()
	badActors2:SetPos(self:GetWide() - 20 - badActors2:GetWide(), 220)

	local flatgrass1 = vgui.Create("DLabel", self)
	flatgrass1:SetText("Serverside Codebase")
	flatgrass1:SetFont("DermaLarge")
	flatgrass1:SetColor(Color(150, 150, 150))
	flatgrass1:SizeToContents()
	flatgrass1:SetY(self:GetTall() - 120)
	flatgrass1:CenterHorizontal()

	local flatgrass2 = vgui.Create("DButton", self)
	flatgrass2:SetText("Kindly provided by Flatgrass.net")
	flatgrass2:SetFont("DermaLarge")
	flatgrass2:SizeToContents()
	flatgrass2:SetY(self:GetTall() - 80)
	flatgrass2:CenterHorizontal()
	flatgrass2.Paint = function(this, width, height)
		local isHovered = this:IsHovered()
		local isDown = this:IsDown()

		this:SetColor(isDown and Color(50, 100, 255) or isHovered and Color(125, 175, 255) or Color(200, 200, 200))
	end
	flatgrass2.DoClick = function()
		gui.OpenURL("https://github.com/flatgrassdotnet/")

		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))
	end
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	local realHeight = (fgHeight / fgWidth) * width

	surface.SetDrawColor(100, 100, 100)
	surface.SetMaterial(flatgrass)
	surface.DrawTexturedRect(0, height - realHeight, width, realHeight)

	surface.SetDrawColor(25, 25, 25)
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

vgui.Register("echoCreditsMenu", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "creditsmenu_OnPauseMenuShow", function()
	if (!IsValid(creditsMenu)) then return end

	creditsMenu:Close()

	return false
end)
