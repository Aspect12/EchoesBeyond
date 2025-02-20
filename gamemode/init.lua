
-- decorate note creation popup
	-- Shows a warning if there's profanity in the note
	-- Shows a warning if you reach the character limit
-- make notes shared between servers
-- make a menu with TAB
	-- Option to toggle music on/off
	-- Option to toggle profanity filter on/off
	-- Game info
	-- Credits
	-- "There are currently X notes across X different maps."
	-- Personal note count & note limit
-- Disable collisions between players
-- Save own written notes
	-- Viewable from the menu
	-- Adds to intro check

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
