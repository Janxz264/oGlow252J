local _G = getfenv(0)
local oGlow = oGlow

local select = select
local ATTACHMENTS_MAX_SEND = ATTACHMENTS_MAX_SEND
local GetSendMailItem = GetSendMailItem

local send = function(self, event)
    if(not SendMailFrame:IsShown()) then return end

    for i = 1, ATTACHMENTS_MAX_SEND do
        local link = GetSendMailItemLink(i)
        local slot = _G["SendMailAttachment" .. i]
        if(link and not oGlow.preventMail) then
            local q = select(3, GetItemInfo(link))
            if q then
                oGlow(slot, q)
            end
        elseif(slot.bc) then
            slot.bc:Hide()
        end
    end
end

local inbox = function(self, event)
    local numItems = GetInboxNumItems()
    local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

    for i = 1, INBOXITEMS_TO_DISPLAY do
        local slot = _G["MailItem" .. i .. "Button"]
        if(index <= numItems) then
            local hq = 0
            for j = 1, ATTACHMENTS_MAX_RECEIVE do
                local link = GetInboxItemLink(index, j)
                if(link) then
                    local quality = select(3, GetItemInfo(link))
                    if quality then
                        hq = math.max(hq, quality)
                    end
                end
            end

            if(hq > 0 and not oGlow.preventMail) then
                oGlow(slot, hq)
            elseif(slot.bc) then
                slot.bc:Hide()
            end
        elseif(slot.bc) then
            slot.bc:Hide()
        end
        index = index + 1
    end
end

local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", function(self, event, ...)
    self[event](self, event, ...)
end)

hooksecurefunc("OpenMail_Update", function(self)
    if(not InboxFrame.openMailID) then return end

    for i = 1, ATTACHMENTS_MAX_RECEIVE do
        local link = GetInboxItemLink(InboxFrame.openMailID, i)
        if(link) then
            local slot = _G["OpenMailAttachmentButton" .. i]
            local q = select(3, GetItemInfo(link))
            if(q and not oGlow.preventMail) then
                oGlow(slot, q)
            elseif(slot.bc) then
                slot.bc:Hide()
            end
        end
    end
end)

hooksecurefunc("InboxFrame_Update", inbox)

addon.MAIL_SHOW = send
addon.MAIL_SEND_INFO_UPDATE = send
addon.MAIL_SEND_SUCCESS = send

addon:RegisterEvent("MAIL_SHOW")
addon:RegisterEvent("MAIL_SEND_INFO_UPDATE")
addon:RegisterEvent("MAIL_SEND_SUCCESS")

oGlow.updateMail = update