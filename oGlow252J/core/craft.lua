local oGlow = oGlow
local frame = CreateFrame("Frame")

local delayedItems = {}

-- Apply glow, or queue if info isn't ready
local function applyGlow(target, link, texture)
    if link and not oGlow.preventCraft then
        local quality = select(3, GetItemInfo(link))
        if quality then
            oGlow(target, quality, texture)
        else
            frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            table.insert(delayedItems, {target = target, link = link, texture = texture})
        end
    elseif target and target.bc then
        target.bc:Hide()
    end
end

-- Update function for selected craft
local function updateCraft(id)
    local icon = _G["CraftIcon"]
    local link = GetCraftItemLink(id)
    applyGlow(icon, link)

    for i = 1, GetCraftNumReagents(id) do
        local reagentFrame = _G["CraftReagent"..i]
        local reagentLink = GetCraftReagentItemLink(id, i)
        local texture = _G["CraftReagent"..i.."IconTexture"]
        applyGlow(reagentFrame, reagentLink, texture)
    end
end

-- Handle item info delay completion
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" and arg1 then
        for i = #delayedItems, 1, -1 do
            local entry = delayedItems[i]
            if entry.link == arg1 then
                local quality = select(3, GetItemInfo(entry.link))
                if quality then
                    oGlow(entry.target, quality, entry.texture)
                    table.remove(delayedItems, i)
                end
            end
        end
        if #delayedItems == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    end
end)

-- Hook into Craft UI lifecycle
if IsAddOnLoaded("Blizzard_CraftUI") then
    hooksecurefunc("CraftFrame_SetSelection", updateCraft)
else
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("ADDON_LOADED")
    watcher:SetScript("OnEvent", function(_, _, addon)
        if addon == "Blizzard_CraftUI" then
            hooksecurefunc("CraftFrame_SetSelection", updateCraft)
            watcher:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

-- Export
oGlow.updateCraft = updateCraft