local oGlow = {}
local colorTable = setmetatable({
    [100] = {r = 0.9, g = 0, b = 0},   -- Custom: red for special tag
    [99]  = {r = 1, g = 1, b = 0},     -- Custom: yellow for alert
}, {
    __call = function(self, val)
        local color = self[val]
        if color then
            return color.r, color.g, color.b
        elseif type(val) == "number" then
            return GetItemQualityColor(val)
        end
    end
})

local function createBorder(frame, point)
    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetAlpha(0.8)
    border:SetSize(70, 70)
    border:SetPoint("CENTER", point or frame)
    frame.bc = border
end

setmetatable(oGlow, {
    __call = function(self, frame, quality, point)
        if not frame then return end

        if (type(quality) == "number" and quality > 1) or type(quality) == "string" then
            if not frame.bc then
                createBorder(frame, point)
            end
            if frame.bc then
                local r, g, b = colorTable(quality)
                frame.bc:SetVertexColor(r, g, b)
                frame.bc:Show()
            end
        elseif frame.bc then
            frame.bc:Hide()
        end
    end
})

function oGlow:RegisterColor(key, r, g, b)
    colorTable[key] = {r = r, g = g, b = b}
end

_G.oGlow = oGlow