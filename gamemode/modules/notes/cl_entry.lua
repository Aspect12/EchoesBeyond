
local PANEL = {}

function PANEL:Init()
	if (IsValid(noteEntry)) then
		noteEntry:Remove()
	end

	noteEntry = self

	self:SetSize(600, 200)
	self:Center()
	self:MakePopup()
	self:SetAlpha(0)

	self.startTime = SysTime()

	self:AlphaTo(255, 0.25)

	local title = vgui.Create("DLabel", self)
	title:SetFont("DermaLarge")
	title:SetText("Echo")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(10)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetFont("DermaDefault")
	subTitle:SetText("Echo your thoughts into the text field below.")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(60)

	self.entry = vgui.Create("DTextEntry", self)
	self.entry:SetWide(self:GetWide() - 40)
	self.entry:Center()
	self.entry:SetY(80)
	self.entry.large = false
	self.entry.OnTextChanged = function(this) -- Add length & profanity warnings
		local text = this:GetValue()

		if (text:len() > 2 and !this.large) then
			self:ToggleSize(true)			

			this.large = true
		elseif (text:len() <= 2 and this.large) then
			self:ToggleSize(false)

			this.large = false
		end
	end
	self.entry.OnKeyCodePressed = function(this, key)
		if (key != KEY_ESCAPE) then return end

		self:Close()
	end
	self.entry:RequestFocus()

	self.submit = vgui.Create("DButton", self)
	self.submit:SetSize(100, 30)
	self.submit:SetText("Submit")
	self.submit:SizeToContents()
	self.submit:CenterHorizontal()
	self.submit:SetY(110)
	self.submit.DoClick = function()
		local message = self.entry:GetValue()

		net.Start("CreateNote")
			net.WriteString(message)
		net.SendToServer()

		self:Close()
	end

	self.cancel = vgui.Create("DButton", self)
	self.cancel:SetSize(100, 30)
	self.cancel:SetText("Cancel")
	self.cancel:SizeToContents()
	self.cancel:CenterHorizontal()
	self.cancel:SetY(155)
	self.cancel.DoClick = function()
		self:Close()
	end
end

function PANEL:ToggleSize(bEnlarge)
	if (bEnlarge) then
		self:SizeTo(self:GetWide(), 400, 0.5)
		self:MoveTo(self:GetX(), ScrH() / 2 - 200, 0.5)
		
		self.entry:SizeTo(self.entry:GetWide(), 220, 0.5)
		self.entry:SetMultiline(true)

		self.submit:MoveTo(self.submit:GetX(), 310, 0.5)
		self.cancel:MoveTo(self.cancel:GetX(), 355, 0.5)			
	else
		self:SizeTo(self:GetWide(), 200, 0.5)
		self:MoveTo(self:GetX(), ScrH() / 2 - 100, 0.5)

		self.entry:SizeTo(self.entry:GetWide(), 20, 0.5, nil, nil, function(animData, targetPanel)
			targetPanel:SetMultiline(false)
		end)

		self.submit:MoveTo(self.submit:GetX(), 110, 0.5)
		self.cancel:MoveTo(self.cancel:GetX(), 155, 0.5)
	end
end

function PANEL:Close()
	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_R and key != KEY_ESCAPE) then return end

	self:Close()
end

local notif = Material("echoesbeyond/notification.png")

function PANEL:Paint(width, height)
	Derma_DrawBackgroundBlur(self, self.startTime)
	
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetDrawColor(200, 200, 200)
	surface.SetMaterial(notif)
	surface.DrawTexturedRect(width * 0.15, 45, width - width * 0.3, 2)
end

vgui.Register("echoEntry", PANEL, "EditablePanel")
