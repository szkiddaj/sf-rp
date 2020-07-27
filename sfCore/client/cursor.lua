local sx, sy = guiGetScreenSize();

bindKey('m', 'down', function()
    if (isInputTyping()) then return; end
    showCursor(not isCursorShowing());
end);

function cursorInZone(x, y, w, h)
    if (not isCursorShowing()) then return false; end
    local cx, cy = getCursorPosition();
    cx, cy = cx*sx, cy*sy;
    return (cx > x and cx < x + w and cy > y and cy < y + h and true or false);
end