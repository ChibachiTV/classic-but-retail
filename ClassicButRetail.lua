-- ClassicButRetail.lua

-- Addon Initialization
local ClassicButRetail = CreateFrame("Frame")

-- Settings
ClassicButRetail_SavedVars = ClassicButRetail_SavedVars or {
    showMobHighlights = false,
    showNPCHighlights = false,
    showMinimap = true,
}

local settings_menu = Settings.RegisterVerticalLayoutCategory("ClassicButRetail")

local function OnSettingChanged(setting, value)
    if setting:GetVariable() == "Show_Quest_Mob_Highlights" then
        SetCVar("ShowQuestUnitCircles", value)

    elseif setting:GetVariable() == "Show_Quest_NPC_Highlights" then
        SetCVar("Outline", value and 2 or 0)

    elseif setting:GetVariable() == "Show_Minimap" then
        if value then
            MinimapCluster:Show()
        else
            MinimapCluster:Hide()
        end
    end
end

local function InitializeSettingsUI()
    local settingsDefs = {
        { name = "Show Quest Mob Highlights", variable = "Show_Quest_Mob_Highlights", variableKey = "showMobHighlights", default = false, tooltip = "Show the glowing, yellow circle under quest mobs?" },
        { name = "Show Quest NPC Highlights", variable = "Show_Quest_NPC_Highlights", variableKey = "showNPCHighlights", default = false, tooltip = "Show the outline or sparkles on NPCs?" },
        { name = "Show Minimap", variable = "Show_Minimap", variableKey = "showMinimap", default = true, tooltip = "Show the minimap?" },
    }
    
    for _, def in ipairs(settingsDefs) do
        local setting = Settings.RegisterAddOnSetting(
            settings_menu,
            def.variable,
            def.variableKey,
            ClassicButRetail_SavedVars,
            "boolean",  -- since all defaults are booleans
            def.name,
            def.default
        )
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateCheckbox(settings_menu, setting, def.tooltip)
    end

    Settings.RegisterAddOnCategory(settings_menu)
end

-- Event Handler Function
local function OnEvent(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "ClassicButRetail" then
        -- Initialize the Settings UI
        InitializeSettingsUI()

        -- Show the mobs under-highlights
        SetCVar("ShowQuestUnitCircles", ClassicButRetail_SavedVars.showMobHighlights and 2 or 0)

        -- This needs to be called every frame in order to suppress the "sparkles" that show up when the highlighting is disabled.
        -- Until Blizzard implements something better, this is all we can do.
        WorldFrame:HookScript("OnUpdate", function()
            SetCVar("Outline", ClassicButRetail_SavedVars.showNPCHighlights and 2 or 0) 
        end)

        -- Default to show all minimap options
        -- Should this also be a toggle? Lol
        SetCVar("minimapTrackingShowAll", 1)

        -- Minimap
        if ClassicButRetail_SavedVars.showMinimap then
            MinimapCluster:Show()
        else
            MinimapCluster:Hide()
        end
    end
end

-- Register Events
ClassicButRetail:RegisterEvent("ADDON_LOADED")

-- Set Event Handler
ClassicButRetail:SetScript("OnEvent", OnEvent)