
local setDrawColor = surface.SetDrawColor
local drawOutlinedRect = surface.DrawOutlinedRect

function PIXEL.DrawOutlinedBox(x, y, w, h, thickness, col)
    setDrawColor(col.r, col.g, col.b, col.a)
    for i = 0, thickness - 1 do
        drawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

local ipairs = ipairs
local setTexture = surface.SetTexture
local drawPoly = surface.DrawPoly
local drawRect = surface.DrawRect

local roundedBoxCache = {}
local whiteTexture = surface.GetTextureID("vgui/white")

function PIXEL.DrawOutlinedRoundedBox(borderSize, x, y, w, h, col, thickness)
    thickness = thickness or 1

    setDrawColor(col.r, col.g, col.b, col.a)

    if borderSize <= 0 then
        PIXEL.DrawOutlinedBox(x, y, w, h, thickness, col)
        return
    end

    local fullRight = x + w
    local fullBottom = y + h

    local left, right = x + borderSize, fullRight - borderSize
    local top, bottom = y + borderSize, fullBottom - borderSize

    local halfBorder = borderSize * .6

    local width, height = w - borderSize * 2, h - borderSize * 2

    drawRect(x, top, thickness, height) --Left
    drawRect(x + w - thickness, top, thickness, height) --Right
    drawRect(left, y, width, thickness) --Top
    drawRect(left, y + h - thickness, width, thickness) --Bottom

    local cacheName = borderSize .. x .. y .. w .. h .. thickness
    local cache = roundedBoxCache[cacheName]
    if not cache then
        cache = {
            { --Top Right
                {x = right, y = y}, --Outer
                {x = right + halfBorder, y = top - halfBorder},
                {x = fullRight, y = top},

                {x = fullRight - thickness, y = top}, --Inner
                {x = right + halfBorder - thickness, y = top - halfBorder + thickness},
                {x = right, y = y + thickness}
            },
            { --Bottom Right
                {x = fullRight, y = bottom}, --Outer
                {x = right + halfBorder, y = bottom + halfBorder},
                {x = right, y = fullBottom},

                {x = right, y = fullBottom - thickness}, --Inner
                {x = right + halfBorder - thickness, y = bottom + halfBorder - thickness},
                {x = fullRight - thickness, y = bottom}
            },
            { --Bottom Left
                {x = left, y = fullBottom}, --Outer
                {x = left - halfBorder, y = bottom + halfBorder},
                {x = x, y = bottom},

                {x = x + thickness, y = bottom}, --Inner
                {x = left - halfBorder + thickness, y = bottom + halfBorder - thickness},
                {x = left, y = fullBottom - thickness},
            },
            { --Top Left
                {x = x, y = top}, --Outer
                {x = left - halfBorder, y = top - halfBorder},
                {x = left, y = y},

                {x = left, y = y + thickness}, --Inner
                {x = left - halfBorder + thickness, y = top - halfBorder + thickness},
                {x = x + thickness, y = top}
            }
        }

        roundedBoxCache[cacheName] = cache
    end

    setTexture(whiteTexture)

    for k,v in ipairs(cache) do
        drawPoly(v)
    end
end