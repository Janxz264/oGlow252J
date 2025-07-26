local oGlow = oGlow
local frame = CreateFrame("Frame")
local delayedQueue = {}

local function applyGlow(slot, link)
    if not slot then return end

    if link and not oGlow.preventTrade then
        local quality = select(3, GetItemInfo(link))
        if quality then
            oGlow(slot, quality)
        else
            frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            table.insert(delayedQueue, {slot = slot, link = link})
        end
    elseif slot.bc then
        slot.bc:Hide()
    end
end

-- Player item glow update
local function updatePlayerItem(index)
    local slot = _G["TradePlayerItem"..index.."ItemButton"]
    local link = GetTradePlayerItemLink(index)
    applyGlow(slot, link)
end

-- Target item glow update
local function updateTargetItem(index)
    local slot = _G["TradeRecipientItem"..index.."ItemButton"]
    local link = GetTradeTargetItemLink(index)
    applyGlow(slot, link)
end

-- Unified update (called on TRADE_SHOW or TRADE_UPDATE)
local function updateTrade()
    for i = 1, 7 do
        updatePlayerItem(i)
        updateTargetItem(i)
    end
end

-- Listen for item info responses
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" and arg1 then
        for i = #delayedQueue, 1, -1 do
            local entry = delayedQueue[i]
            if entry.link == arg1 then
                local q = select(3, GetItemInfo(arg1))
                if q then
                    oGlow(entry.slot, q)
                    table.remove(delayedQueue, i)
                end
            end
        end
        if #delayedQueue == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    end
end)

-- TradeFrame event listener
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TRADE_SHOW")
eventFrame:RegisterEvent("TRADE_UPDATE")
eventFrame:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
eventFrame:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "TRADE_PLAYER_ITEM_CHANGED" then
        updatePlayerItem(arg1)
    elseif event == "TRADE_TARGET_ITEM_CHANGED" then
        updateTargetItem(arg1)
    else
        updateTrade()
    end
end)

-- Export
oGlow.updateTrade = updateTrade