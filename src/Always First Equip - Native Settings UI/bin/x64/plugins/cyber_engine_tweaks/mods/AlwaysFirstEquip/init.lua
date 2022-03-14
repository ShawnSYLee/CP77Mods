local defaults = {
	PercentageProbability = 50,
	PlayInCombatMode = false,
	PlayInStealthMode = false,
	PlayWhenMagazineIsEmpty = false,
	PlayWhileSprinting = false,
	ExcludeArmsCyberware = true,
	TrackLastUsedSlot = true,
	DefaultSlotNumber = 1,
	AnimationProbability = 10,
	AnimationCheckPeriod = 5,
	BindToHotkeyIdleBreak = true
}

local settings = {
	PercentageProbability = 50,
	PlayInCombatMode = false,
	PlayInStealthMode = false,
	PlayWhenMagazineIsEmpty = false,
	PlayWhileSprinting = false,
	ExcludeArmsCyberware = true,
	TrackLastUsedSlot = true,
	DefaultSlotNumber = 1,
	AnimationProbability = 10,
	AnimationCheckPeriod = 5,
	BindToHotkeyIdleBreak = true
}

function SaveSettings() 
	local validJson, contents = pcall(function() return json.encode(settings) end)
	
	if validJson and contents ~= nil then
		local updatedFile = io.open("settings.json", "w+");
		updatedFile:write(contents);
		updatedFile:close();
	end
end

function LoadSettings() 
	local file = io.open("settings.json", "r")
	if file ~= nil then
		local contents = file:read("*a")
		local validJson, persistedState = pcall(function() return json.decode(contents) end)
		
		if validJson then
			file:close();
			for key, _ in pairs(settings) do
				if persistedState[key] ~= nil then
					settings[key] = persistedState[key]
				end
			end
		end
	end
end

function SetupSettingsMenu()
	local nativeSettings = GetMod("nativeSettings")
	
	if not nativeSettings then
		print("Error: NativeSettings not found!")
		return
	end

	nativeSettings.addTab("/equip", "First Equip")
	
	nativeSettings.addSubcategory("/equip/common", "Common config")
	
	nativeSettings.addRangeInt("/equip/common", "Percentage probability", "Defines firstEquip animation probability in percents", 0, 100, 5, settings.PercentageProbability, defaults.PercentageProbability, function(value)
		settings.PercentageProbability = value
	end)
	
	nativeSettings.addSwitch("/equip/common", "Play in combat mode", "Enable if you want see firstEquip animation while in combat mode", settings.PlayInCombatMode, defaults.PlayInCombatMode, function(state)
		settings.PlayInCombatMode = state
	end)
	
	nativeSettings.addSwitch("/equip/common", "Play in stealth mode", "Enable if you want see firstEquip animation while in stealth mode", settings.PlayInStealthMode, defaults.PlayInStealthMode, function(state)
		settings.PlayInStealthMode = state
	end)
	
	nativeSettings.addSwitch("/equip/common", "Play when magazine is empty", "Enable if you want see firstEquip animation when weapon magazine is empty", settings.PlayWhenMagazineIsEmpty, defaults.PlayWhenMagazineIsEmpty, function(state)
		settings.PlayWhenMagazineIsEmpty = state
	end)
	
	nativeSettings.addSwitch("/equip/common", "Play while sprinting", "Enable if you want see firstEquip animation while sprinting", settings.PlayWhileSprinting, defaults.PlayWhileSprinting, function(state)
		settings.PlayWhileSprinting = state
	end)
	
	nativeSettings.addSwitch("/equip/common", "Exclude arms cyberware", "Enable if you want to prevent probability based animations for arms cyberware (Gorilla Arms, Projectile Launcher, Mantis Blades and Nano Wire)", settings.ExcludeArmsCyberware, defaults.ExcludeArmsCyberware, function(state)
		settings.ExcludeArmsCyberware = state
	end)
	

	nativeSettings.addSubcategory("/equip/hotkey", "Hotkey config")
	
	nativeSettings.addSwitch("/equip/hotkey", "Track last used slot", "If enabled then mod tracks slots usage and hotkey press equips weapon from the last used slot, otherwise it uses default slot number defined below", settings.TrackLastUsedSlot, defaults.TrackLastUsedSlot, function(state)
		settings.TrackLastUsedSlot = state
	end)
	
	nativeSettings.addRangeInt("/equip/hotkey", "Default slot number", "Default slot which used if track last used slot option disabled", 1, 4, 1, settings.DefaultSlotNumber, defaults.DefaultSlotNumber, function(value)
		-- print("Changed SLIDER INT to ", value)
		settings.DefaultSlotNumber = value
	end)
	
	nativeSettings.addSubcategory("/equip/idle", "IdleBreak config")

	nativeSettings.addSwitch("/equip/idle", "Bind to hotkey", "If enabled then you can trigger IdleBreak animation with a preconfigured hotkey", settings.BindToHotkeyIdleBreak, defaults.BindToHotkeyIdleBreak, function(state)
		settings.BindToHotkeyIdleBreak = state
	end)

	nativeSettings.addRangeInt("/equip/idle", "Animation probability", "Set IdleBreak animation probability in percents", 1, 100, 5, settings.AnimationProbability, defaults.AnimationProbability, function(value)
		settings.AnimationProbability = value
	end)
	
	nativeSettings.addRangeInt("/equip/idle", "Animation check period", "Animation checks period in seconds, each check decides if animation should be played when V stands still based on probability value from previous option", 1, 100, 5, settings.AnimationCheckPeriod, defaults.AnimationCheckPeriod, function(value)
		settings.AnimationCheckPeriod = value
	end)
end

registerForEvent("onInit", function()

	LoadSettings()
	SetupSettingsMenu()
	
	Override("FirstEquipConfig", "PercentageProbability;", function(_) return settings.PercentageProbability end)
	Override("FirstEquipConfig", "PlayInCombatMode;", function(_) return settings.PlayInCombatMode end)
	Override("FirstEquipConfig", "PlayInStealthMode;", function(_) return settings.PlayInStealthMode end)
	Override("FirstEquipConfig", "PlayWhenMagazineIsEmpty;", function(_) return settings.PlayWhenMagazineIsEmpty end)
	Override("FirstEquipConfig", "PlayWhileSprinting;", function(_) return settings.PlayWhileSprinting end)
	Override("FirstEquipConfig", "ExcludeArmsCyberware;", function(_) return settings.ExcludeArmsCyberware end)
	Override("FirstEquipConfig", "TrackLastUsedSlot;", function(_) return settings.TrackLastUsedSlot end)
	Override("FirstEquipConfig", "DefaultSlotNumber;", function(_) return settings.DefaultSlotNumber end)
	Override("IdleBreakConfig", "AnimationProbability;", function(_) return settings.AnimationProbability end)
	Override("IdleBreakConfig", "AnimationCheckPeriod;", function(_) return settings.AnimationCheckPeriod end)
	Override("IdleBreakConfig", "BindToHotkey;", function(_) return settings.BindToHotkeyIdleBreak end)

end)

registerForEvent("onShutdown", function()
    SaveSettings()
end)