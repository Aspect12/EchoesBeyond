
local noteMat = Material("echoesbeyond/note_simple.png", "smooth")
local vignette = Material("echoesbeyond/vignette.png", "smooth")

-- The map menu
local PANEL = {}

function PANEL:Init()
	if (IsValid(mapMenu)) then
		mapMenu:Remove()
	end

	mapMenu = self

	self:SetSize(ScrW() / 4, ScrH() / 1.5)
	self:Center()
	self:MakePopup()
	self.startTime = SysTime()
	self:SetAlpha(0)

	self:AlphaTo(255, 0.5)
	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Map List")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("Below is a list of all " .. mapCount .. " maps with Echoes in them.")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	local mapListPanel = vgui.Create("DScrollPanel", self)
	mapListPanel:SetSize(self:GetWide() - 20, self:GetTall() - 140)
	mapListPanel:SetPos(10, 100)
	mapListPanel.Paint = function(this, width, height)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, this:GetWide(), this:GetTall())

	end
	mapListPanel.VBar.Paint = function(this, width, height)
		surface.SetDrawColor(15, 15, 15)
		surface.DrawRect(0, 0, this:GetWide(), this:GetTall())
	end
	mapListPanel.VBar.btnGrip.Paint = function(this, width, height)
		surface.SetDrawColor(5, 5, 5)
		surface.DrawRect(0, 0, mapListPanel.VBar.btnGrip:GetWide(), mapListPanel.VBar.btnGrip:GetTall())
	end
	mapListPanel.VBar.btnUp.Paint = function() end
	mapListPanel.VBar.btnDown.Paint = function() end

	for i = 1, #mapList do
		local map = vgui.Create("DLabel", mapListPanel)
		map:SetText(mapList[i])
		map:SizeToContents()
		map:Dock(TOP)
		map:SetContentAlignment(5)
		map:DockMargin(0, 0, 0, 5)
	end
end

function PANEL:Paint(width, height)
	Derma_DrawBackgroundBlur(self, self.startTime)

	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)

	local breatheLayer = math.sin(CurTime() * 1.5)

	surface.SetDrawColor(255, 255, 255, 5)
	surface.SetMaterial(noteMat)
	surface.DrawTexturedRectRotated(width / 2, height / 2 + 5 * breatheLayer, height / 1.5, height / 1.5, 0)
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_TAB) then return end

	self:Close()
end

function PANEL:Close()
	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)
end

vgui.Register("echoMapMenu", PANEL, "DPanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "mapmenu_OnPauseMenuShow", function()
	if (!IsValid(mapMenu)) then return end

	mapMenu:Close()

	return false
end)
