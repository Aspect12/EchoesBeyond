
local PANEL = {}

local maxSmallLength = 49 -- Max text length before the text field expands
local maxBigSize = 256 -- Max text length

function PANEL:Init()
	if (IsValid(noteEntry)) then
		noteEntry:Remove()
	end

	noteEntry = self

	self:SetSize(600, 210)
	self:Center()
	self:MakePopup()
	self:SetAlpha(0)

	self.startTime = SysTime()

	self:AlphaTo(255, 0.25)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetFont("DermaLarge")
	title:SetText("Create Echo")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(10)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("Echo your thoughts into the text field below.")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(60)

	self.entry = vgui.Create("DTextEntry", self)
	self.entry:SetSize(self:GetWide() - 40, 30)
	self.entry:CenterHorizontal()
	self.entry:SetFont("HudDefault")
	self.entry:SetY(85)
	self.entry.OnTextChanged = function(this) -- Add length & profanity warnings
		local text = this:GetValue()
		local length = text:len()

		if (length > maxBigSize) then
			this:SetText(text:sub(1, maxBigSize))
			this:SetCaretPos(maxBigSize)

			self:ToggleWarning(true, false)
		else
			self:ToggleWarning(false, false)
		end

		if (IsOffensive(text)) then
			self:ToggleWarning(true, true)
		else
			self:ToggleWarning(false, true)
		end

		if (length > maxSmallLength and !self.large) then
			self.large = true
			self:ToggleSize(true)

		elseif (length <= maxSmallLength and self.large) then
			self:ToggleSize(false)
			self.large = false
		end
	end
	self.entry.OnKeyCodePressed = function(this, key)
		if (key != KEY_ESCAPE) then return end

		self:Close()
	end
	self.entry.Paint = function(this, width, height)
		surface.SetDrawColor(50, 50, 50)
		surface.DrawRect(0, 0, width, height)

		this:DrawTextEntryText(Color(175, 175, 175), color_white, Color(175, 175, 175))
	end
	self.entry:RequestFocus()

	self.submit = vgui.Create("DButton", self)
	self.submit:SetSize(self:GetWide() * 0.3, 30)
	self.submit:SetText("Submit")
	self.submit:SetFont("CreditsText")
	self.submit:SetColor(Color(175, 175, 175))
	self.submit:CenterHorizontal()
	self.submit:SetY(125)
	self.submit.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
	end
	self.submit.DoClick = function()
		CreateNote(self.entry:GetValue())

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

local warningTypes = {
	[true] = "A wise message avoids profanity and hate speech.",
	[false] = "A wise message is concise and to the point."
}

function PANEL:ToggleWarning(bState, bAlt)
	if (bState) then
		if (IsValid(self["warning" .. (bAlt and "Offensive" or "Length")])) then return end

		local warning = vgui.Create("DLabel", self)
		warning:SetText(warningTypes[bAlt])
		warning:SetColor(bAlt and Color(255, 50, 50) or Color(255, 255, 75))
		warning:SizeToContents()
		warning:CenterHorizontal()
		warning:SetY(((IsValid(self.warningOffensive) or IsValid(self.warningLength)) and 100) or 80)
		warning:SetAlpha(0)
		warning:AlphaTo(255, 0.25)

		self["warning" .. (bAlt and "Offensive" or "Length")] = warning
		self:ToggleSize(true)
	elseif (IsValid(self["warning" .. (bAlt and "Offensive" or "Length")])) then
		local warning = self["warning" .. (bAlt and "Offensive" or "Length")]
		warning.removing = true

		warning:AlphaTo(0, 0.25, 0, function()
			warning:Remove()
		end)

		self:ToggleSize(true)
	end
end

function PANEL:ToggleSize(bEnlarge)
	if (bEnlarge) then
		local extra = 0
		local bLarge = self.large

		if (IsValid(self.warningLength) and !self.warningLength.removing) then
			extra = extra + 20
		end

		if (IsValid(self.warningOffensive) and !self.warningOffensive.removing) then
			extra = extra + 20
		end

		if (bLarge) then
			LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)
		end

		self:SizeTo(self:GetWide(), (bLarge and 310 or 210) + extra, 0.5)
		self:MoveTo(self:GetX(), ScrH() / 2 - ((bLarge and 155 or 100) + extra / 2), 0.5)

		self.entry:MoveTo(self.entry:GetX(), 85 + extra, 0.5)
		self.entry:SizeTo(self.entry:GetWide(), bLarge and 130 or 30, 0.5)
		self.entry:SetMultiline(true)

		self.submit:MoveTo(self.submit:GetX(), (bLarge and 225 or 125) + extra, 0.5)
		self.cancel:MoveTo(self.cancel:GetX(), (bLarge and 265 or 165) + extra, 0.5)
	else
		local extra = 0

		if (IsValid(self.warningLength) and !self.warningLength.removing) then
			extra = extra + 20
		end

		if (IsValid(self.warningOffensive) and !self.warningOffensive.removing) then
			extra = extra + 20
		end

		if (self.large) then
			LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)
		end

		self:SizeTo(self:GetWide(), 210 + extra, 0.5)
		self:MoveTo(self:GetX(), ScrH() / 2 - 100 + extra / 2, 0.5)

		self.entry:MoveTo(self.entry:GetX(), 85 + extra, 0.5)
		self.entry:SizeTo(self.entry:GetWide(), 30, 0.5, nil, nil, function(animData, targetPanel)
			targetPanel:SetMultiline(false)
		end)

		self.submit:MoveTo(self.submit:GetX(), 125 + extra, 0.5)
		self.cancel:MoveTo(self.cancel:GetX(), 165 + extra, 0.5)
	end
end

function PANEL:Close()
	self:AlphaTo(0, 0.25, 0, function()
		self:Remove()
	end)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 90, 0.75)
end

function PANEL:OnKeyCodePressed(key)
	if (key != KEY_R and key != KEY_TAB) then return end

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

vgui.Register("echoEntry", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "entry_OnPauseMenuShow", function()
	if (!IsValid(noteEntry)) then return end

	noteEntry:Close()

	return false
end)
