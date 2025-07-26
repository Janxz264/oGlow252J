if select(4, GetAddOnInfo("Fizzle")) then return end

local oGlow = oGlow
local frame = CreateFrame("Frame")

local slots = {
    [1]  = "Head",         [2]  = "Neck",        [3]  = "Shoulder",
    [4]  = "Shirt",        [5]  = "Chest",       [6]  = "Waist",
    [7]  = "Legs",         [8]  = "Feet",        [9]  = "Wrist",
    [10] = "Hands",        [11] = "Finger0",     [12] = "Finger1",
    [13] = "Trinket0",     [14] = "Trinket1",    [15] = "Back",
    [16] = "MainHand",     [17] = "SecondaryHand",[18] = "Ranged",
    [19] = "Tabard"
}

local function getItemID(link)
    return tonumber(link and link:match("item:(%d+)"))
end

local delayedItems = {}
local hasRetry = false

local function applyGlow(slotName, link)
    local button = _G["Inspect"..slotName.."Slot"]
    if not button then return end

    if link and not oGlow.preventInspect then
        local quality = select(3, GetItemInfo(link))
        if quality then
            oGlow(button, quality)
        else
            local itemID = getItemID(link)
            if itemID then
                table.insert(delayedItems, {slot = button, itemID = itemID})
                frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            end
        end
    elseif button.bc then
        button.bc:Hide()
    end
end

local function updateInspect()
    if not InspectFrame:IsShown() then return end
    local unit = InspectFrame.unit
    if not UnitExists(unit) then return end

    for slotID, slotName in pairs(slots) do
        local link = GetInventoryItemLink(unit, slotID)
        applyGlow(slotName, link)
    end
end

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" then
        for i = #delayedItems, 1, -1 do
            local entry = delayedItems[i]
            if entry.itemID == arg1 then
                local quality = select(3, GetItemInfo(arg1))
                if quality then
                    oGlow(entry.slot, quality)
                    table.remove(delayedItems, i)
                end
            end
        end
        if #delayedItems == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end

    elseif event == "PLAYER_TARGET_CHANGED" then
        updateInspect()

    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_InspectUI" then
        InspectFrame:HookScript("OnShow", function()
            updateInspect()
            if not hasRetry then
                hasRetry = true
                C_Timer.After(0.5, function()
                    updateInspect()
                    hasRetry = false
                end)
            end
        end)
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    end
end)

if IsAddOnLoaded("Blizzard_InspectUI") then
    InspectFrame:HookScript("OnShow", function()
        updateInspect()
        if not hasRetry then
            hasRetry = true
            C_Timer.After(0.5, function()
                updateInspect()
                hasRetry = false
            end)
        end
    end)
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
else
    frame:RegisterEvent("ADDON_LOADED")
end

oGlow.updateInspect = updateInspect