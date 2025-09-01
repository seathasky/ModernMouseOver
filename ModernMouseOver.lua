
local addonName, addon = ...

local frame = CreateFrame("Frame", "ModernMouseOverFrame", UIParent)
frame:SetSize(350, 200)
frame:SetPoint("CENTER")
frame:Hide()
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0,0,0,1)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Title
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("BOTTOM", frame, "TOP", 0, 5)
frame.title:SetText("ModernMouseOver Macro Maker")

-- Custom Close Button for 3.3.5 (must be after frame creation)
local closeButton = CreateFrame("Button", nil, frame)
closeButton:SetSize(24, 24)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
closeButton:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
closeButton:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
closeButton:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
closeButton:SetScript("OnClick", function() frame:Hide() end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
    SLASH_MODERNMOUSEOVER1 = "/mmm"
    SlashCmdList["MODERNMOUSEOVER"] = function()
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end)

-- Spell Name Label
local spellLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
spellLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
spellLabel:SetText("Spell Name:")

local spellBox = CreateFrame("EditBox", "MMM_SpellBox", frame)
spellBox:SetSize(140, 20)
spellBox:SetPoint("LEFT", spellLabel, "RIGHT", 10, 0)
spellBox:SetAutoFocus(false)
spellBox:SetMaxLetters(50)
spellBox:SetText("Blessing of Might")
spellBox:EnableMouse(true)
spellBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
spellBox:SetTextColor(1, 1, 1, 1)
spellBox:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
spellBox:SetBackdropColor(0, 0, 0, 0.8)
spellBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
spellBox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Spell Name InputBox", 1, 1, 1)
    GameTooltip:Show()
end)
spellBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Rank Label
local rankLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rankLabel:SetPoint("TOPLEFT", spellLabel, "BOTTOMLEFT", 0, -15)
rankLabel:SetText("Rank:")

local rankBox = CreateFrame("EditBox", "MMM_RankBox", frame)
rankBox:SetSize(40, 20)
rankBox:SetPoint("LEFT", rankLabel, "RIGHT", 10, 0)
rankBox:SetAutoFocus(false)
rankBox:SetMaxLetters(2)
rankBox:SetText("1")
rankBox:EnableMouse(true)
rankBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
rankBox:SetTextColor(1, 1, 1, 1)
rankBox:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
rankBox:SetBackdropColor(0, 0, 0, 0.8)
rankBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
rankBox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Rank InputBox", 1, 1, 1)
    GameTooltip:Show()
end)
rankBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Message Label
local messageLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
messageLabel:SetPoint("TOPLEFT", rankBox, "BOTTOMLEFT", 0, -15)
messageLabel:SetText("")

local addButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
addButton:SetPoint("TOPLEFT", messageLabel, "BOTTOMLEFT", 0, -5)
addButton:SetSize(100, 25)
addButton:SetText("Add")

-- Macro Page Button
local macroPageButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
macroPageButton:SetPoint("LEFT", addButton, "RIGHT", 10, 0)
macroPageButton:SetSize(100, 25)
macroPageButton:SetText("Open Macros")
macroPageButton:SetScript("OnClick", function()
    if not MacroFrame or not MacroFrame:IsShown() then
        ShowMacroFrame()
    end
end)

addButton:SetScript("OnClick", function(self)
    local spell = spellBox:GetText():gsub("%s+$", "")
    local rank = rankBox:GetText():gsub("%s+$", "")
    if spell == "" then
        messageLabel:SetText("Please enter a spell name.")
        return
    end
    
    -- Handle spells without ranks (rank 0 or empty)
    local hasRank = rank ~= "" and rank ~= "0"
    local macroText, macroName
    
    if hasRank then
        -- Spell with rank
        macroText = "#showtooltip [@mouseover,help,nodead][] " .. spell .. "(Rank " .. rank .. ")\n/cast [@mouseover,help,nodead] [@player] " .. spell .. "(Rank " .. rank .. ")"
        local cleanSpell = spell:gsub(" ", "_")
        macroName = "MMM_" .. cleanSpell .. "_R" .. rank
        
        -- If the name is too long, shorten the spell part intelligently
        if strlen(macroName) > 16 then
            local maxSpellLength = 16 - 4 - strlen(rank) - 2  -- 4 for "MMM_", 2 for "_R"
            if maxSpellLength > 0 then
                cleanSpell = cleanSpell:sub(1, maxSpellLength)
                macroName = "MMM_" .. cleanSpell .. "_R" .. rank
            else
                -- If still too long, just truncate
                macroName = macroName:sub(1, 16)
            end
        end
    else
        -- Spell without rank
        macroText = "#showtooltip [@mouseover,help,nodead][] " .. spell .. "\n/cast [@mouseover,help,nodead] [@player] " .. spell
        local cleanSpell = spell:gsub(" ", "_")
        macroName = "MMM_" .. cleanSpell
        
        -- If the name is too long, shorten it
        if strlen(macroName) > 16 then
            local maxSpellLength = 16 - 4  -- 4 for "MMM_"
            cleanSpell = cleanSpell:sub(1, maxSpellLength)
            macroName = "MMM_" .. cleanSpell
        end
    end
    
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex == 0 then
        -- No existing macro found, create a new one
        macroIndex = CreateMacro(macroName, 1, macroText, 0)
    else
        -- Macro exists, update it
        EditMacro(macroIndex, macroName, 1, macroText, 0)
    end
    
    if macroIndex and macroIndex > 0 then
        local foundSlot = false
        for slot = 1, 120 do
            local actionType, id = GetActionInfo(slot)
            if not actionType then
                -- Empty slot, safe to use
                PickupMacro(macroIndex)
                PlaceAction(slot)
                ClearCursor()
                messageLabel:SetText("Macro created and placed in slot " .. slot)
                foundSlot = true
                break
            elseif actionType == "macro" then
                -- Check if this slot has the same macro we just created
                local slotMacroName = GetMacroInfo(id)
                if slotMacroName == macroName then
                    -- This slot already has our macro, no need to place again
                    messageLabel:SetText("Macro updated in slot " .. slot)
                    foundSlot = true
                    break
                end
            end
        end
        if not foundSlot then
            messageLabel:SetText("Macro created! Check your macro frame or drag to action bar.")
        end
    else
        messageLabel:SetText("Failed to create macro")
    end
end)
