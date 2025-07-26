local G = _G
local oGlow = oGlow

local frame = CreateFrame("Frame")
frame:Hide()

local delay = 0
local pendingBags = {}

-- Core update function for a single bag
local function updateBag(bagFrame, bagID)
    local name = bagFrame:GetName()
    local size = bagFrame.size
    if not size then return end

    for slotID = 1, size do
        -- Option 1: Use reversed index to match pre-WotLK visual order
        local reversedID = size - slotID + 1
        local button = G[name.."Item"..reversedID]

        -- Option 2 (alternative): safer access via dynamic keys
        -- local button = bagFrame["item"..slotID]

        local link = GetContainerItemLink(bagID, slotID)
        if link and not oGlow.preventBags then
            local quality = select(3, GetItemInfo(link))
            if not quality then
                frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
                pendingBags[link] = pendingBags[link] or {}
                table.insert(pendingBags[link], button)
            else
                oGlow(button, quality)
            end
        elseif button and button.bc then
            button.bc:Hide()
        end
    end
end

-- Handle delayed item info caching
frame:SetScript("OnEvent", function(_, event, link)
    if event == "GET_ITEM_INFO_RECEIVED" and pendingBags[link] then
        local quality = select(3, GetItemInfo(link))
        if quality then
            for _, button in ipairs(pendingBags[link]) do
                oGlow(button, quality)
            end
        end
        pendingBags[link] = nil
    end
end)

-- Periodic update loop
frame:SetScript("OnUpdate", function(self, elapsed)
    delay = delay + elapsed
    if delay > 0.05 then
        for bagFrame, bagID in pairs(pendingBags.updateQueue or {}) do
            updateBag(bagFrame, bagID)
        end
        pendingBags.updateQueue = nil
        delay = 0
        frame:Hide()
    end
end)

-- Track which bags to refresh
local function queueUpdate(bagFrame)
    pendingBags.updateQueue = pendingBags.updateQueue or {}
    pendingBags.updateQueue[bagFrame] = bagFrame:GetID()
    frame:Show()
end

-- Hook bag show/hide events
hooksecurefunc("ContainerFrame_OnShow", function(self)
    frame:RegisterEvent("BAG_UPDATE")
    queueUpdate(self)
end)

hooksecurefunc("ContainerFrame_OnHide", function(self)
    if not ContainerFrame1:IsShown() then
        frame:UnregisterEvent("BAG_UPDATE")
        frame:Hide()
    end
end)

-- Hook when bags receive item updates
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", function(_, event, id)
    for i = 1, NUM_CONTAINER_FRAMES do
        local bagFrame = G["ContainerFrame"..i]
        if bagFrame and bagFrame:IsShown() and bagFrame:GetID() == id then
            queueUpdate(bagFrame)
            break
        end
    end
end)

-- Export
oGlow.updateBags = updateBag