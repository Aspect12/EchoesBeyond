
-- A simple notification system

if (SERVER) then
	util.AddNetworkString("echoNotify")
else
	echoNotif = echoNotif or nil
	local PANEL = {}

	function PANEL:Init()
		self:SetSize(ScrW() * 0.75, 50)
		self:CenterHorizontal()
		self:SetY(-self:GetTall())
		self:SetAlpha(0)

		if (IsValid(echoNotif)) then
			echoNotif:SlideOut()
		end

		echoNotif = self
	end

	function PANEL:Setup(text)
		self:AlphaTo(255, 1)
		self:MoveTo(self:GetX(), 25, 0.5, 0, 0.5, function()
			self:AlphaTo(0, 1, 5)
			self:SlideOut(5)
		end)

		local label = vgui.Create("DLabel", self)
		label:SetFont("HudDefault")
		label:SetText(text)
		label:SizeToContents()
		label:Center()

		LocalPlayer():EmitSound("echoesbeyond/notification.wav", 75, math.random(95, 105))
	end

	function PANEL:SlideOut(delay)
		self:MoveTo(self:GetX(), -self:GetTall(), 0.5, delay or 0, -0.5, function()
			self:Remove()
		end)
	end

	local notif = Material("echoesbeyond/notification.png")

	function PANEL:Paint(width, height)
		surface.SetDrawColor(25, 25, 25, 225)
		surface.SetMaterial(notif)
		surface.DrawTexturedRect(0, 0, width, height)
	end

	vgui.Register("echoNotification", PANEL, "DPanel")

	net.Receive("echoNotify", function()
		EchoNotify(net.ReadString())
	end)
end

function EchoNotify(client, text)
	if (SERVER) then
		net.Start("echoNotify")
			net.WriteString(text)
		net.Send(client)
	else
		text = client -- client is actually the text here

		local notifPanel = vgui.Create("echoNotification")
		notifPanel:Setup(text)
	end
end
