local oGlow = oGlow
local frame = CreateFrame("Frame")
frame:Hide()

local delayedSlots = {}

-- Apply glow or queue for retry
local function applyGlow(slot, link)
    if link and not oGlow.preventGBank then
        local quality = select(3, GetItemInfo(link))
        if quality then
            oGlow(slot, quality)
        else
            frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
            table.insert(delayedSlots, {slot = slot, link = link})
        end
    elseif slot and slot.bc then
        slot.bc:Hide()
    end
end

-- Update glow for all slots in active tab
local function updateGBank()
    local tab = GetCurrentGuildBankTab()
    for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local index = i % NUM_SLOTS_PER_GUILDBANK_GROUP
        if index == 0 then index = NUM_SLOTS_PER_GUILDBANK_GROUP end
        local column = math.ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
        local slot = _G["GuildBankColumn"..column.."Button"..index]
        local link = GetGuildBankItemLink(tab, i)
        applyGlow(slot, link)
    end
end

-- OnUpdate throttle for guild bank changes
local delay = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    delay = delay + elapsed
    if delay > 0.05 then
        updateGBank()
        delay = 0
        frame:Hide()
    end
end)

-- Respond to events
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" and arg1 then
        for i = #delayedSlots, 1, -1 do
            local entry = delayedSlots[i]
            if entry.link == arg1 then
                local quality = select(3, GetItemInfo(arg1))
                if quality then
                    oGlow(entry.slot, quality)
                    table.remove(delayedSlots, i)
                end
            end
        end
        if #delayedSlots == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    elseif event == "GUILDBANKFRAME_OPENED" then
        frame:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
        frame:Show()
    elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
        frame:Show()
    elseif event == "GUILDBANKFRAME_CLOSED" then
        frame:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
        frame:Hide()
    end
end)

-- Register initial events
frame:RegisterEvent("GUILDBANKFRAME_OPENED")
frame:RegisterEvent("GUILDBANKFRAME_CLOSED")

-- Export
oGlow.updateGBank = updateGBank