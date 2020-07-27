function dxDrawGradientRectangle(x, y, w, h, color1, color2)
    local count = 0;
    while (count < w) do
        local r, g, b = interpolateBetween(color1[1], color1[2], color1[3], color2[1], color2[2], color2[3], count / w, 'Linear');
        dxDrawRectangle(x + (count * 1), y, 1, h, tocolor(r, g, b));
        count = count + 1;
    end
end

function dxDrawButton(text, x, y, w, h, font, border, basecolor, hovercolor, clickcolor, textcolor, bordercolor)
    if (not border) then border = 2; end
    if (not font) then font = 'default'; end
    if (not textcolor) then textcolor = tocolor(255, 255, 255); end
    if (not bordercolor) then bordercolor = basecolor; end

    dxDrawRectangle(x, y, w, h, bordercolor);
    if (cursorInZone(x, y, w, h)) then 
        if (getKeyState('mouse1')) then 
            dxDrawRectangle(x + border, y + border, w - border * 2, h - border * 2, clickcolor);
        else 
            dxDrawRectangle(x + border, y + border, w - border * 2, h - border * 2, hovercolor);
        end
    else 
        dxDrawRectangle(x + border, y + border, w - border * 2, h - border * 2, basecolor);
    end

    dxDrawText(text, x, y, x + w, y + h, textcolor, 1, font, 'center', 'center');
end

function dxDrawRoundedRectangle(x, y, rx, ry, color, radius)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color)
        dxDrawRectangle(x, y - radius, rx, radius, color)
        dxDrawRectangle(x, y + ry, rx, radius, color)
        dxDrawRectangle(x - radius, y, radius, ry, color)
        dxDrawRectangle(x + rx, y, radius, ry, color)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7)
    end
end