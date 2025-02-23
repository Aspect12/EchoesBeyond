
local vignette = Material("echoesbeyond/vignette.png", "smooth")

-- The map menu
local PANEL = {}

function PANEL:Init()
	if (IsValid(mapMenu)) then
		mapMenu:Remove()
	end

	mapMenu = self

	self.mapList = {}

	self:SetSize(ScrW() / 4, ScrH() / 1.5)
	self:Center()
	self:SetX(mainMenu:GetX() - self:GetWide() - 10)
	self:MakePopup()
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

	local subSubTitle = vgui.Create("DLabel", self)
	subSubTitle:SetText("Click on a map to search for it in the Steam Workshop.")
	subSubTitle:SizeToContents()
	subSubTitle:CenterHorizontal()
	subSubTitle:SetY(75)

	local searchBar = vgui.Create("DTextEntry", self)
	searchBar:SetSize(self:GetWide() - 20, 20)
	searchBar:SetPos(10, 100)
	searchBar:SetPlaceholderText("Search for a map...")
	searchBar.OnChange = function(this)
		local search = this:GetValue():lower()

		self:ListMaps(search)
	end
	searchBar.Paint = function(this, width, height)
		surface.SetDrawColor(50, 50, 50, 255)
		surface.DrawRect(0, 0, width, height)

		this:DrawTextEntryText(color_white, color_white, color_white)
	end

	self.mapListPanel = vgui.Create("DScrollPanel", self)
	self.mapListPanel:SetPos(10, 130)
	self.mapListPanel:SetSize(self:GetWide() - 20, self:GetTall() - 140)
	self.mapListPanel.Paint = function(this, width, height)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, this:GetWide(), this:GetTall())

	end
	self.mapListPanel.VBar.Paint = function(this, width, height)
		surface.SetDrawColor(35, 35, 35)
		surface.DrawRect(0, 0, this:GetWide(), this:GetTall())
	end
	self.mapListPanel.VBar.btnGrip.Paint = function(this, width, height)
		surface.SetDrawColor(45, 45, 45)
		surface.DrawRect(0, 0, self.mapListPanel.VBar.btnGrip:GetWide(), self.mapListPanel.VBar.btnGrip:GetTall())
	end
	self.mapListPanel.VBar.btnUp.Paint = function() end
	self.mapListPanel.VBar.btnDown.Paint = function() end

	self:ListMaps()
end

function PANEL:ListMaps(filter)
	for _, entry in pairs(self.mapList) do
		entry:Remove()
	end

	if (filter) then
		filter = filter:Trim()
	end

	self.mapList = {}

	for name, amount in SortedPairsByValue(mapList, true) do
		if (filter and !name:lower():find(filter:lower())) then continue end

		local entry = vgui.Create("DPanel", self.mapListPanel)
		entry:Dock(TOP)
		entry:DockPadding(5, 0, 15, 0)
		entry:SetTall(20)
		entry:DockMargin(0, 0, 0, 5)
		entry:SetPaintBackground(false)

		local mapName = vgui.Create("DButton", entry)
		mapName:SetText(name)
		mapName:SizeToContents()
		mapName:Dock(LEFT)
		mapName:SetContentAlignment(4)
		mapName:SetPaintBackground(false)
		mapName:SetTextColor(color_white)
		mapName.Think = function(this)
			if (this:IsHovered()) then
				this:SetTextColor(Color(0, 125, 255))
			else
				this:SetTextColor(color_white)
			end
		end
		mapName.DoClick = function(this)
			gui.OpenURL("https://steamcommunity.com/workshop/browse/?appid=4000&searchtext=" .. name .. "&requiredtags%5B%5D=Map&requiredtags%5B%5D=Addon")
		end

		local noteCount = vgui.Create("DLabel", entry)
		noteCount:SetText(amount .. " Echoes")
		noteCount:SizeToContents()
		noteCount:Dock(RIGHT)
		noteCount:SetContentAlignment(6)

		self.mapList[name] = entry
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

vgui.Register("echoMapMenu", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "mapmenu_OnPauseMenuShow", function()
	if (!IsValid(mapMenu)) then return end

	mapMenu:Close()

	return false
end)
