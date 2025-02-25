
local PANEL = {}

function PANEL:Init()
	if (IsValid(echoConfirmation)) then
		echoConfirmation:Remove()
	end

	echoConfirmation = self

	self:SetSize(600, 210)
	self:Center()
	self:MakePopup()
	self:SetAlpha(0)

	self.startTime = SysTime()

	self:AlphaTo(255, 0.25)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	self.title = vgui.Create("DLabel", self)
	self.title:SetFont("DermaLarge")
	self.title:SetText("Confirmation Title")
	self.title:SizeToContents()
	self.title:CenterHorizontal()
	self.title:SetY(10)

	self.subTitle = vgui.Create("DLabel", self)
	self.subTitle:SetText("Echo your thoughts into the text field below.")
	self.subTitle:SizeToContents()
	self.subTitle:CenterHorizontal()
	self.subTitle:SetY(60)

	self.submit = vgui.Create("DButton", self)
	self.submit:SetSize(self:GetWide() * 0.3, 30)
	self.submit:SetText("Confirm")
	self.submit:SetFont("CreditsText")
	self.submit:SetColor(Color(175, 175, 175))
	self.submit:CenterHorizontal()
	self.submit:SetY(125)
	self.submit.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
	end
	self.submit.DoClick = function()
		if (self.callback) then
			self.callback()
		end

		self:Close()

		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))
	end

	self.cancel = vgui.Create("DButton", self)
	self.cancel:SetSize(self:GetWide() * 0.3, 30)
	self.cancel:SetText("Cancel")
	self.cancel:SetFont("CreditsText")
	self.cancel:SetColor(Color(175, 175, 175))
	self.cancel:CenterHorizontal()
	self.cancel:SetY(165)
	self.cancel.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
	end
	self.cancel.DoClick = function()
		self:Close()

		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))
	end
end

function PANEL:Populate(title, text, callback)
	self.title:SetText(title)
	self.title:SizeToContents()
	self.title:CenterHorizontal()

	self.subTitle:SetText(text)
	self.subTitle:SizeToContents()
	self.subTitle:CenterHorizontal()

	self.callback = callback
end

function PANEL:Close()
	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_TAB) then return end

	self:Close()
end

local notif = Material("echoesbeyond/notification.png")
local vignette = Material("echoesbeyond/vignette.png")

function PANEL:Paint(width, height)
	Derma_DrawBackgroundBlur(self, self.startTime)

	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)

	surface.SetDrawColor(200, 200, 200)
	surface.SetMaterial(notif)
	surface.DrawTexturedRect(width * 0.15, 45, width - width * 0.3, 2)
end

vgui.Register("EchoesConfirm", PANEL, "DPanel")

function EchoesConfirm(title, text, callback)
	vgui.Create("EchoesConfirm"):Populate(title, text, callback)
end

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "entry_OnPauseMenuShow", function()
	if (!IsValid(echoConfirmation)) then return end

	echoConfirmation:Close()

	return false
end)
