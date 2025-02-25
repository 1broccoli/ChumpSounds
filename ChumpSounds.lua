local Sounds = {}
local ChumpSoundsDB

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_FACTION")
frame:RegisterEvent("ADDON_LOADED") -- Register ADDON_LOADED event

-- Remove PLAYER_FOCUS_CHANGED registration if "focus" is unavailable
if _G.UnitExists("focus") then
	frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
end

local function initializeSettings()
	if not ChumpSoundsDB then
		ChumpSoundsDB = {
			npcSound = true,
			playerSound = true,
			neutralSound = true,
			lostTargetSound = true
		}
	end
	_G.ChumpSoundsDB = ChumpSoundsDB
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and ... == "ChumpSounds" then
		-- Load saved variables if they exist
		if _G.ChumpSoundsDB then
			ChumpSoundsDB = _G.ChumpSoundsDB
		else
			initializeSettings()
		end
		self:UnregisterEvent("ADDON_LOADED")
	else
		if Sounds[event] then
			Sounds[event](Sounds, ...)
		end
	end
end)

-- Helper function
local function shouldPlaySound(condition, soundSetting)
	return condition and ChumpSoundsDB[soundSetting]
end

-- Target sounds
function Sounds:PLAYER_TARGET_CHANGED()
	if UnitExists("target") then
		if shouldPlaySound(UnitIsEnemy("target", "player"), "npcSound") then
			PlaySound(867) -- "igCreatureAggroSelect"
		elseif shouldPlaySound(UnitIsFriend("player", "target"), "playerSound") then
			PlaySound(867) -- "igCharacterNPCSelect"
		elseif shouldPlaySound(not UnitIsEnemy("target", "player") and not UnitIsFriend("player", "target"), "neutralSound") then
			PlaySound(867) -- "igCreatureNeutralSelect"
		end
	else
		if ChumpSoundsDB.lostTargetSound then
			PlaySound(867) -- "INTERFACESOUND_LOSTTARGETUNIT"
		end
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

-- Slash commands
local function saveSettings()
	_G.ChumpSoundsDB = ChumpSoundsDB
end

SLASH_CHUMPSOUNDS1 = "/chumpsounds"
SlashCmdList["CHUMPSOUNDS"] = function(msg)
    local command, value = strsplit(" ", msg, 2)
    local function getStatus(enabled)
        return enabled and "|cff00ff00(ON)|r" or "|cffff0000(OFF)|r"
    end

    if command == "npc" then
        ChumpSoundsDB.npcSound = not ChumpSoundsDB.npcSound
        print("NPC targeting sound " .. (ChumpSoundsDB.npcSound and "enabled" or "disabled"))
    elseif command == "player" then
        ChumpSoundsDB.playerSound = not ChumpSoundsDB.playerSound
        print("Player targeting sound " .. (ChumpSoundsDB.playerSound and "enabled" or "disabled"))
    elseif command == "neutral" then
        ChumpSoundsDB.neutralSound = not ChumpSoundsDB.neutralSound
        print("Neutral targeting sound " .. (ChumpSoundsDB.neutralSound and "enabled" or "disabled"))
    elseif command == "lost" then
        ChumpSoundsDB.lostTargetSound = not ChumpSoundsDB.lostTargetSound
        print("Lost target sound " .. (ChumpSoundsDB.lostTargetSound and "enabled" or "disabled"))
    else
        print("|cffffffff/chumpsounds|r commands:")
        print("|cffffffff/chumpsounds npc|r - Toggle NPC targeting sound " .. getStatus(ChumpSoundsDB.npcSound))
        print("|cffffffff/chumpsounds player|r - Toggle player targeting sound " .. getStatus(ChumpSoundsDB.playerSound))
        print("|cffffffff/chumpsounds neutral|r - Toggle neutral targeting sound " .. getStatus(ChumpSoundsDB.neutralSound))
        print("|cffffffff/chumpsounds lost|r - Toggle lost target sound " .. getStatus(ChumpSoundsDB.lostTargetSound))
    end
    -- Save settings only if they were changed
    saveSettings()
end