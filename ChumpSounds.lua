local Sounds = {}

-- Target sounds
function Sounds:PLAYER_TARGET_CHANGED()
	if UnitExists("target") then
		if UnitIsEnemy("target", "player") then
			PlaySound(867) -- "igCreatureAggroSelect"
		elseif UnitIsFriend("player", "target") then
			PlaySound(867) -- "igCharacterNPCSelect"
		else
			PlaySound(867) -- "igCreatureNeutralSelect"
		end
	else
		PlaySound(867) -- "INTERFACESOUND_LOSTTARGETUNIT"
	end
end

-- PVP flag sounds
local announcedPVP
function Sounds:UNIT_FACTION(unit)
	if unit ~= "player" then return end

	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound(4574) -- "igPVPUpdate"
		end
	else
		announcedPVP = nil
	end
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_FACTION")

-- Remove PLAYER_FOCUS_CHANGED registration if "focus" is unavailable
if _G.UnitExists("focus") then
	frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
end

frame:SetScript("OnEvent", function(self, event, ...)
	if Sounds[event] then
		Sounds[event](Sounds, ...)
	end
end)
