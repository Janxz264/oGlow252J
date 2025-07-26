if select(4, GetAddOnInfo("Fizzle")) then return end

local oGlow = oGlow

-- Equipment slot mapping: slotID => slotName
local items = {
    [0] = "Ammo",
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [4] = "Shirt",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger0",
    [12] = "Finger1",
    [13] = "Trinket0",
    [14] = "Trinket1",
    [15] = "Back",
    [16] = "MainHand",
    [17] = "SecondaryHand",
    [18] = "Ranged",
    [19] = "Tabard"
}

local function updateCharacter()
    if not CharacterFrame:IsShown() then return end

    for slotID, slotName in pairs(items) do
        local button = _G["Character"..slotName.."Slot"]
        if button then
            local quality = GetInventoryItemQuality("player", slotID)

            if oGlow.preventCharacter then
                quality = nil
            elseif GetInventoryItemBroken("player", slotID) then
                quality = 100 -- 🔴 Custom red glow for broken
            elseif GetInventoryAlertStatus(slotID) == 3 then
                quality = 99 -- 🟡 Custom yellow glow for warning
            end

            oGlow(button, quality)
        end
    end
end

local f = CreateFrame("Frame", nil, CharacterFrame)
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:SetScript("OnEvent", function(_, _, unit)
    if unit == "player" then
        updateCharacter()
    end
end)

CharacterFrame:HookScript("OnShow", updateCharacter)

oGlow.updateCharacter = updateCharacter