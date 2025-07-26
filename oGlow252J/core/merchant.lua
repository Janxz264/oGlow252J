local oGlow = oGlow
local frame = CreateFrame("Frame")
local delayedQueue = {}

local function applyGlow(slot, link)
    if not slot then return end

    if link and (not oGlow.preventMerchant or not oGlow.preventBuyback) then
        local quality = select(3, GetItemInfo(link))
        if quality then
            oGlow(slot, quality)
        else
            table.insert(delayedQueue, {slot = slot, link = link})
            frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    elseif slot.bc then
        slot.bc:Hide()
    end
end

local function updateMerchant()
    local isMainTab = (MerchantFrame.selectedTab == 1)
    local numItems = isMainTab and GetMerchantNumItems() or GetNumBuybackItems()

    for i = 1, MERCHANT_ITEMS_PER_PAGE do
        local index = ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i
        local link = isMainTab and GetMerchantItemLink(index) or GetBuybackItemLink(index)
        local slot = _G["MerchantItem"..i.."ItemButton"]

        if link then
            if isMainTab and not oGlow.preventMerchant then
                applyGlow(slot, link)
            elseif not isMainTab and not oGlow.preventBuyback then
                applyGlow(slot, link)
            elseif slot.bc then
                slot.bc:Hide()
            end
        elseif slot.bc then
            slot.bc:Hide()
        end
    end
end

-- Retry queue for item info
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "GET_ITEM_INFO_RECEIVED" and arg1 then
        for i = #delayedQueue, 1, -1 do
            local entry = delayedQueue[i]
            if entry.link == arg1 then
                local quality = select(3, GetItemInfo(arg1))
                if quality then
                    oGlow(entry.slot, quality)
                    table.remove(delayedQueue, i)
                end
            end
        end
        if #delayedQueue == 0 then
            frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
    end
end)

hooksecurefunc("MerchantFrame_Update", updateMerchant)

-- Export
oGlow.updateMerchant = updateMerchant