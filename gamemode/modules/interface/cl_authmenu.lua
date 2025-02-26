
local echoMat = Material("echoesbeyond/echo_simple.png", "smooth")
local echoBlankMat = Material("echoesbeyond/echo_simple_blank.png", "smooth")
local vignette = Material("echoesbeyond/vignette.png", "smooth")
local throbberMat = Material("echoesbeyond/echo_simple_dots.png", "nocull")
local steamMat = Material("echoesbeyond/steam.png", "smooth")

local PANEL = {}

function PANEL:Init()
	if (IsValid(authMenu)) then
		authMenu:Remove()
	end

	authMenu = self

	local width, height = ScrW() / 2.5, ScrH() / 2

	self:SetSize(width, height)
	self:Center()
	self:MakePopup()
	self:SetAlpha(0)
	self:AlphaTo(255, 0.5)

	LocalPlayer():EmitSound("echoesbeyond/whoosh.wav", 75, 100, 0.75)

	local title = vgui.Create("DLabel", self)
	title:SetText("Echoes Beyond - Authentication")
	title:SetFont("DermaLarge")
	title:SizeToContents()
	title:CenterHorizontal()
	title:SetY(20)

	local subTitle = vgui.Create("DLabel", self)
	subTitle:SetText("Please authenticate to create new Echoes.")
	subTitle:SizeToContents()
	subTitle:CenterHorizontal()
	subTitle:SetY(55)

	self.text1 = vgui.Create("DLabel", self)
	self.text1:SetText("To create new Echoes, you must first authenticate with your Steam account.")
	self.text1:SetFont("TargetID")
	self.text1:SizeToContents()
	self.text1:CenterHorizontal()
	self.text1:SetY(height / 2 - 70)

	self.text2 = vgui.Create("DLabel", self)
	self.text2:SetText("This is to prevent abuse and ensure a safe and welcoming environment for all players.")
	self.text2:SetFont("TargetID")
	self.text2:SizeToContents()
	self.text2:CenterHorizontal()
	self.text2:SetY(height / 2 - 50)

	self.text3 = vgui.Create("DLabel", self)
	self.text3:SetText("The only data we collect is your SteamID, for use in authentication and moderation.")
	self.text3:SetFont("TargetID")
	self.text3:SizeToContents()
	self.text3:CenterHorizontal()
	self.text3:SetY(height / 2 - 30)

	self.text4 = vgui.Create("DLabel", self)
	self.text4:SetText("You will be prompted to log in to our website with your Steam account.")
	self.text4:SetFont("TargetID")
	self.text4:SizeToContents()
	self.text4:CenterHorizontal()
	self.text4:SetY(height / 2 + 10)

	self.text5 = vgui.Create("DLabel", self)
	self.text5:SetText("Click the button below to begin.")
	self.text5:SetFont("TargetID")
	self.text5:SizeToContents()
	self.text5:CenterHorizontal()
	self.text5:SetY(height / 2 + 30)

	self.throbber = vgui.Create("DPanel", self) -- lol, funny name
	self.throbber:SetSize(height / 1.5, height / 1.5)
	self.throbber:Center()
	self.throbber.Paint = function(this, width, height)
		local breatheLayer = math.sin(CurTime() * 1.5)

		surface.SetDrawColor(255, 255, 255, 5)
		surface.SetMaterial(echoBlankMat)
		surface.DrawTexturedRectRotated(width / 2, height / 2  + 5 * breatheLayer, width, height, 0)

		surface.SetDrawColor(255, 255, 255, 195)
		surface.SetMaterial(throbberMat)
		surface.DrawTexturedRectRotated(width / 2, height / 2  + 5 * breatheLayer, width, height, CurTime() * -150)
	end
	self.throbber:SetAlpha(0)

	self.wait = vgui.Create("DLabel", self)
	self.wait:SetText("Please wait while we authenticate you...")
	self.wait:SetFont("TargetID")
	self.wait:SizeToContents()
	self.wait:Center()
	self.wait:SetAlpha(0)

	local buttonHeight = (100 / 669) * width * 0.3

	local authButton = vgui.Create("DButton", self)
	authButton:SetSize(width * 0.3, buttonHeight)
	authButton:SetText("")
	authButton:CenterHorizontal()
	authButton:SetY(height - 50 - 10 - buttonHeight)
	authButton.Paint = function(this, width, height)
		local isHovered = this:IsHovered()
		local isDown = this:IsDown()
		local color = isDown and Color(200, 200, 200) or isHovered and Color(225, 225, 225) or Color(175, 175, 175)

		surface.SetDrawColor(color)
		surface.SetMaterial(steamMat)
		surface.DrawTexturedRect(0, 0, width, height)
	end
	authButton.DoClick = function(this)
		local ticket = GenerateHex()

		gui.OpenURL("https://resonance.flatgrass.net/login?ticket=" .. ticket)

		for i = 1, 5 do
			if (!IsValid(self["text" .. i])) then continue end

			self["text" .. i]:AlphaTo(0, 0.5, 0, function()
				self["text" .. i]:Remove()
			end)
		end

		this:AlphaTo(0, 0.5)
		this:SetMouseInputEnabled(false)

		self.throbber:AlphaTo(255, 0.5)
		self.wait:AlphaTo(0, 0.5, 0, function(animData, this)
			this:SetText("Please wait while we authenticate you...")
			this:SizeToContents()
			this:Center()

			this:AlphaTo(255, 0.5, 0, function()
				timer.Simple(10, function()
					if (!IsValid(this)) then return end

					this:AlphaTo(0, 0.5, 0, function()
						if (!IsValid(this)) then return end

						this:SetText("This is taking longer than expected. Please stand by...")
						this:SizeToContents()
						this:Center()

						this:AlphaTo(255, 0.5, 0, function()
							if (!IsValid(this)) then return end

							timer.Simple(10, function()
								if (!IsValid(this)) then return end

								this:AlphaTo(0, 0.5, 0, function()
									if (!IsValid(this)) then return end

									this:SetText("Something went wrong. Please try again or contact the developers.")
									this:SizeToContents()
									this:Center()

									authButton:SetMouseInputEnabled(true)
									authButton:AlphaTo(255, 0.5)

									this:AlphaTo(255, 0.5)
									self.throbber:AlphaTo(0, 0.5)

									timer.Remove("echoAuthCheck")
								end)
							end)
						end)
					end)
				end)
			end)
		end)

		timer.Create("echoAuthCheck", 1, 300, function()
			http.Fetch("https://resonance.flatgrass.net/login/finish?ticket=" .. ticket, function(body, _, _, code)
				if (code != 200) then return end

				timer.Remove("echoAuthCheck")
				self:Close()
				authToken = body

				file.Write("echoesbeyond/authtoken.txt", "DO NOT DELETE, MODIFY, OR SHARE THIS FILE\n" .. authToken)

				EchoNotify("Authentication successful! Welcome to Echoes Beyond.")
			end)
		end)

		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))
	end

	local cancel = vgui.Create("DButton", self)
	cancel:SetSize(width * 0.3, 30)
	cancel:SetText("Cancel")
	cancel:SetFont("CreditsText")
	cancel:SetColor(Color(175, 175, 175))
	cancel:CenterHorizontal()
	cancel:SetY(height - 50)
	cancel.Paint = function(this, width, height)
		surface.SetDrawColor(this:IsDown() and Color(100, 100, 100) or this:IsHovered() and Color(75, 75, 75) or Color(50, 50, 50))
		surface.DrawRect(0, 0, width, height)
	end
	cancel.DoClick = function()
		self:Close()

		LocalPlayer():EmitSound("echoesbeyond/button_click.wav", 75, math.random(95, 105))
	end
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(25, 25, 25)
	surface.DrawRect(0, 0, width, height)

	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(0, 0, width, height)

	local breatheLayer = math.sin(CurTime() * 1.5)
	local alpha = self.throbber:GetAlpha()
	alpha = 5 - (alpha / 255) * 5

	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(echoMat)
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

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)

	timer.Remove("echoAuthCheck")
end

vgui.Register("echoAuthMenu", PANEL, "DPanel")

hook.Add("OnPauseMenuShow", "authmenu_OnPauseMenuShow", function()
	if (!IsValid(authMenu)) then return end

	authMenu:Close()

	return false
end)

hook.Add("HUDPaint", "authmenu_HUDPaint", function()
	if (!IsValid(authMenu)) then return end
	local alpha = authMenu:GetAlpha()

	surface.SetDrawColor(25, 25, 25, 200 * (alpha / 255))
	surface.DrawRect(0, 0, ScrW(), ScrH())
end)
