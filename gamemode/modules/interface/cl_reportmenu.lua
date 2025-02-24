
local vignette = Material("echoesbeyond/vignette.png", "smooth")
local echoMat = Material("echoesbeyond/echo_simple.png", "smooth")

local PANEL = {}

function PANEL:Init()
	if (IsValid(reportMenu)) then
		reportMenu:Remove()
	end

	reportMenu = self

	self:SetSize(ScrW() / 4, ScrH() / 1.5)
	self:Center()
	self:SetX(mainMenu:GetX() + mainMenu:GetWide() + 10)
	self:MakePopup()
	self:SetAlpha(0)

	self:AlphaTo(255, 0.5)
	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Echo Reports")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("Vote & Report Echoes here.")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	local subSubTitle = vgui.Create("DLabel", self)
	subSubTitle:SetText("An Echo must reach a score of +10 or -10 for automatic action to be taken.")
	subSubTitle:SizeToContents()
	subSubTitle:CenterHorizontal()
	subSubTitle:SetY(75)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)

	local breatheLayer = math.sin(CurTime() * 1.5)

	surface.SetDrawColor(255, 255, 255, 5)
	surface.SetMaterial(echoMat)
	surface.DrawTexturedRectRotated(width / 2, height / 2 + 5 * breatheLayer, width / 1.5, width / 1.5, 0)

	draw.SimpleText("WIP. Check back soon.", "DermaLarge", width / 2, height / 2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

vgui.Register("echoReportMenu", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "reportmenu_OnPauseMenuShow", function()
	if (!IsValid(reportMenu)) then return end

	reportMenu:Close()

	return false
end)
