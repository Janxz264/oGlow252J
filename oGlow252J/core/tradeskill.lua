local oGlow = oGlow
local frame = CreateFrame("Frame")
local delayedItems = {}

local function applyGlow(target, link, texture)
    if not target then return end

    if link and not oGlow.preventTradeskill then
        local quality = select(3, GetItemInfo(link))
        if quality then
            oGlow(target, quality, texture)
        else
            table.insert(delayedItems, {target = target, link = link, texture = texture})
            frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    elseif target.bc then
        target.bc:Hide()
    end
end

local function updateTradeskill(id)
    local icon = _G["TradeSkillSkillIcon"]
    local link = GetTradeSkillItemLink(id)
    applyGlow(icon, link)

    for i = 1, GetTradeSkillNumReagents(id) do
        local reagentFrame = _G["TradeSkillReagent"..i]
        local reagentLink = GetTradeSkillReagentItemLink(id, i)
        local texture = _G["TradeSkillReagent"..i.."IconTexture"]
        applyGlow(reagentFrame, reagentLink, texture)
    end
end

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" and arg1 then
        for i = #delayedItems, 1, -1 do
            local entry = delayedItems[i]
            if entry.link == arg1 then
                local q = select(3, GetItemInfo(arg1))
                if q then
                    oGlow(entry.target, q, entry.texture)
                    table.remove(delayedItems, i)
                end
            end
        end
        if #delayedItems == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    end
end)

if IsAddOnLoaded("Blizzard_TradeSkillUI") then
    hooksecurefunc("TradeSkillFrame_SetSelection", updateTradeskill)
else
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("ADDON_LOADED")
    loader:SetScript("OnEvent", function(_, _, addon)
        if addon == "Blizzard_TradeSkillUI" then
            hooksecurefunc("TradeSkillFrame_SetSelection", updateTradeskill)
            loader:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

-- Export
oGlow.updateTradeskill = updateTradeskill