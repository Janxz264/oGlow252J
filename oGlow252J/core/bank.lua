local oGlow = oGlow
local frame = CreateFrame("Frame", nil, BankFrame)

local delayedLinks = {}
local bankButtons = {}

-- Highlight bank slot if item info is cached
local function applyGlow(button, link)
    local quality = select(3, GetItemInfo(link))
    if quality then
        oGlow(button, quality)
    else
        table.insert(delayedLinks, {button = button, link = link})
        frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    end
end

-- Update bank slots
local function updateBank()
    for i = 1, 28 do
        local button = _G["BankFrameItem"..i]
        local link = GetContainerItemLink(-1, i)

        if link and not oGlow.preventBank then
            applyGlow(button, link)
        elseif button and button.bc then
            button.bc:Hide()
        end
    end
end

-- Handle item info delay
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" and arg1 then
        for i = #delayedLinks, 1, -1 do
            local entry = delayedLinks[i]
            if entry.link == arg1 then
                local quality = select(3, GetItemInfo(entry.link))
                if quality then
                    oGlow(entry.button, quality)
                    table.remove(delayedLinks, i)
                end
            end
        end
        if #delayedLinks == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    elseif event == "PLAYERBANKSLOTS_CHANGED" then
        updateBank()
    end
end)

-- Trigger on show
frame:SetScript("OnShow", updateBank)
frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

-- Export
oGlow.updateBank = updateBank