local sx, sy = guiGetScreenSize();

function cursorInZone(x, y, w, h)
    if (not isCursorShowing()) then return; end
    local cx, cy = getCursorPosition();
    cx, cy = sx * cx, sy * cy;
    return (cx > x and cx < x + w and cy > y and cy < y + h) and true or false;
end

function dxDrawScrollbar(x, y, w, h, background, color, inner, index, lines, rows)
    local visible = math.min(lines / rows, 1.0);
    visible = math.max(visible, 0.05);
    local bar = h * visible;
    local pos = math.min(index / rows, 1.0 - visible) * h;
    dxDrawRectangle(x, y, w, h, background);
    dxDrawRectangle(x + inner, y + pos + inner, w - inner * 2, bar - inner * 2, color);
end