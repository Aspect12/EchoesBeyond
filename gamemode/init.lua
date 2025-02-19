
-- decorate note creation popup
-- create notification system
-- prevent creating notes too close to each other
-- prevent creating notes too close to spawnpoints
-- make notes shared between servers
-- prevent hateful comments (profanity filter, use regex or something?)
	-- or maybe mark them as red and have a tab menu that allows you to show them? could be cooler
		-- auto-enable the profanity option if a player writes something with profanity

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
