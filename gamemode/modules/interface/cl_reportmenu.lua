
local vignette = Material("echoesbeyond/vignette.png", "smooth")
local vote = Material("echoesbeyond/vote.png", "smooth")

-- The report menu
local function ToggleMusic(bEnabled)
	local music = GetConVar("echoes_music")

	if (bEnabled) then
		music:SetBool(true)
		PlayMusic()
	else
		music:SetBool(false)
		StopMusic()
	end
end

local function ToggleProfanity(bEnabled)
	local profanity = GetConVar("echoes_profanity")

	if (bEnabled) then
		profanity:SetBool(true)
	else
		profanity:SetBool(false)
	end
end

local PANEL = {}

-- Temp
local reportList = {
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -9
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -8
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -7
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -6
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -5
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -4
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -3
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -2
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = -1
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 0
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 1
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 2
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 3
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 4
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 5
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 6
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 7
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 8
	},
	{
		id = "1234567890",
		text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer ac magna vel neque molestie ultricies. Duis in est augue. Sed scelerisque augue risus, at suscipit massa dignissim a. Integer mattis, lacus ut iaculis tristique, magna ante porta justo, eu accumsan orci augue eget neque. Suspendisse ut justo nec risus eleifend luctus eu id ipsum. Vivamus ullamcorper lorem eget nisi volutpat egestas. Curabitur laoreet erat vel ante mattis, a accumsan lectus consectetur. Sed bibendum consequat nunc ut vestibulum",
		score = 9
	},
}

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

	local reportListPanel = vgui.Create("DScrollPanel", self)
	reportListPanel:SetPos(10, 110)
	reportListPanel:SetSize(self:GetWide() - 20, self:GetTall() - 120)
	reportListPanel.Paint = function(this, width, height)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, width, height)
	end
	reportListPanel.VBar.Paint = function(this, width, height)
		surface.SetDrawColor(35, 35, 35)
		surface.DrawRect(0, 0, this:GetWide(), this:GetTall())
	end
	reportListPanel.VBar.btnGrip.Paint = function(this, width, height)
		surface.SetDrawColor(45, 45, 45)
		surface.DrawRect(0, 0, reportListPanel.VBar.btnGrip:GetWide(), reportListPanel.VBar.btnGrip:GetTall())
	end
	reportListPanel.VBar.btnUp.Paint = function() end
	reportListPanel.VBar.btnDown.Paint = function() end

	for k, v in ipairs(reportList) do
		local report = vgui.Create("DPanel", reportListPanel)
		report:SetSize(reportListPanel:GetWide() - 35, 125)
		report:SetPos(10, (k - 1) * 135)
		report.Paint = function(this, width, height)
			surface.SetDrawColor(35, 35, 35)
			surface.DrawRect(0, 0, width, height)
		end

		report.voteColumn = vgui.Create("DPanel", report)
		report.voteColumn:Dock(RIGHT)
		report.voteColumn:SetWide(40)
		report.voteColumn.Paint = function(this, width, height)
			surface.SetDrawColor(50, 50, 50)
			surface.DrawRect(0, 0, width, height)

			local voteColor = color_white
			local score = v.score

			if (score > 0) then
				voteColor = Color(255 - 255 * (score / 10), 255, 255 - 255 * (score / 10))
			elseif (score < 0) then
				voteColor = Color(255, 255 + 255 * (score / 10), 255 + 255 * (score / 10))
			end

			draw.SimpleText(v.score, "DermaLarge", width / 2, height / 2, voteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		report.text = vgui.Create("DTextEntry", report) -- Text entry for wrapping
		report.text:Dock(FILL)
		report.text:DockMargin(5, 5, 10, 5)
		report.text:SetMultiline(true)
		report.text:SetEditable(false)
		report.text:SetFont("DermaDefault")
		report.text:SetText(v.text)
		report.text:SetTextColor(color_white)
		report.text:SetDrawBackground(false)

		report.voteUp = vgui.Create("DButton", report.voteColumn)
		report.voteUp:Dock(TOP)
		report.voteUp:SetTall(30)
		report.voteUp:SetText("")
		report.voteUp:SetTextColor(color_white)
		report.voteUp.Paint = function(this, width, height)
			local isHovered = this:IsHovered()
			local isDown = this:IsDown()

			surface.SetDrawColor(isHovered and !isDown and 75 or 50, isDown and 125 or isHovered and 100 or 75, isHovered and !isDown and 75 or 50)
			surface.DrawRect(0, 0, width, height)

			surface.SetDrawColor(200, 200, 200)
			surface.SetMaterial(vote)
			surface.DrawTexturedRectRotated(width / 2, height / 2, 13, 13, 0)
		end

		report.voteDown = vgui.Create("DButton", report.voteColumn)
		report.voteDown:Dock(BOTTOM)
		report.voteDown:SetTall(30)
		report.voteDown:SetText("")
		report.voteDown:SetTextColor(color_white)
		report.voteDown.Paint = function(this, width, height)
			local isHovered = this:IsHovered()
			local isDown = this:IsDown()

			surface.SetDrawColor(isHovered and !isDown and 125 or isHovered and 100 or 75, isHovered and !isDown and 75 or 50, isHovered and 75 or 50)
			surface.DrawRect(0, 0, width, height)

			surface.SetDrawColor(200, 200, 200)
			surface.SetMaterial(vote)
			surface.DrawTexturedRectRotated(width / 2, height / 2, 13, 13, 180)
		end
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

vgui.Register("echoReportMenu", PANEL, "EditablePanel")

-- Close when pressing escape
hook.Add("OnPauseMenuShow", "reportmenu_OnPauseMenuShow", function()
	if (!IsValid(reportMenu)) then return end

	reportMenu:Close()

	return false
end)
