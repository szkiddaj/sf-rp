local inputs = {};
local order = {};
local current;
local backspaceTimer;

function addInput(id, text, placeholder, textend, x, y, w, h, color, outlinecolor, radius, font, xalign, yalign, placeholdernovalue, masked)
    inputs[id] = {
        text = text,
        textend = textend or '', --[[ pl: valami 'KG' ]]
        x = x, 
        y = y, 
        w = w, 
        h = h,
        font = font or 'arial',
        placeholder = placeholder or '',
        xalign = xalign or 'left',
        yalign = yalign or 'center',
        radius = radius or 2,
        inner = inner or 1,
        base = dxCreateShader(requestRoundRectangleShader(false)),
        outline = dxCreateShader(requestRoundRectangleShader(true)),
        active = false,
        lastbackspace = getTickCount(),
        phnovalue = placeholdernovalue or false,
        masked = masked or false,
    };

    table.insert(order, id);

    if (color) then dxSetShaderValue(inputs[id].base, 'color', {color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255} or {1, 1, 1, 1}); end
    if (outlinecolor) then dxSetShaderValue(inputs[id].outline, 'color', {outlinecolor[1] / 255, outlinecolor[2] / 255, outlinecolor[3] / 255, outlinecolor[4] / 255} or {1, 1, 1, 1}); end
    if (radius) then dxSetShaderValue(inputs[id].base, 'radius', {radius, radius, radius, radius} or {0.25, 0.25, 0.25, 0.25}); end
    if (radius) then dxSetShaderValue(inputs[id].outline, 'radius', {radius, radius, radius, radius} or {0.25, 0.25, 0.25, 0.25}); end
end

function destroyInput(id)
    if (inputs[id]) then 
        destroyElement(inputs[id].base);
        destroyElement(inputs[id].outline);

        for i,v in ipairs(order) do 
            if (v == id) then 
                table.remove(order, i);
                break;
            end
        end

        inputs[id] = nil;

        if (current and id == current.id) then 
            current = nil;
        end
    end
end

function getInputText(id)
    if (inputs[id]) then 
        return inputs[id].text;
    end
    return false;
end

function setInputProperty(id, prop, value)
    if (inputs[id]) then 
        inputs[id][prop] = value;
    end
end

function isInputTyping()
    return (current and true or false);
end

addEventHandler('onClientPreRender', root, function()
    for i,v in pairs(inputs) do 

        local textWidth = dxGetTextWidth(v.text, 1, v.font);

        if (current and current.id == i) then 
            dxDrawImage(v.x - v.inner, v.y - v.inner, v.w + v.inner * 2, v.h + v.inner * 2, v.outline, 0, 0, 0, _, true);
        end

        dxDrawImage(v.x, v.y, v.w, v.h, v.base, 0, 0, 0, _, true);

        if (not v.text or v.text == '' or string.len(v.text) <= 0) then 
            dxDrawText(v.placeholder .. (v.phnovalue and '' or v.textend), v.x + 10, v.y, v.x + v.w - 6, v.y + v.h, tocolor(255, 255, 255, 150), 1, v.font, v.xalign, v.yalign, true, false, true);
        else
            local text = v.masked and string.rep("*", string.len(v.text)) or v.text .. v.textend;
            if (v.w > textWidth) then 
                dxDrawText(text, v.x + 10, v.y, v.x + v.w - 6, v.y + v.h, tocolor(255, 255, 255), 1, v.font, v.xalign, v.yalign, true, false, true); 
            else 
                dxDrawText(text, v.x + 10, v.y, v.x + v.w - 6, v.y + v.h, tocolor(255, 255, 255), 1, v.font, 'right', 'center', true, false, true); 
            end
        end
    end

    if (current) then 
        if (getKeyState('backspace')) then 
            local input = inputs[current.id];
            if (input.lastbackspace + 200 < getTickCount()) then 
                input.text = input.text:gsub("[%z\1-\127\194-\244][\128-\191]*$", "");
                input.lastbackspace = getTickCount();
            end
        end
    end
end);

addEventHandler('onClientClick', root, function(button, state)
    if (isCursorShowing() and button == 'left' and state == 'down') then 
        for i,v in ipairs(order) do 
            if (cursorInZone(inputs[v].x, inputs[v].y, inputs[v].w, inputs[v].h)) then 
                current = { id = v, order = i };
                toggleAllControls(false, true, false);
                return;
            end
        end

        toggleAllControls(true, true, true);
        current = nil;
    end
end);

addEventHandler('onClientCharacter', root, function(char)
    if (isCursorShowing() and current) then 
        if (inputs[current.id]) then 
            inputs[current.id].text = inputs[current.id].text .. char;
        end
    end
end);

addEventHandler('onClientKey', root, function(key, press)
    if (isCursorShowing()) then
        if (key == 'tab' and press) then 
            if (current) then 
                if (#order > current.order) then 
                    current.order = current.order + 1;
                    current.id = order[current.order];
                else 
                    current.order = 1;
                    current.id = order[current.order];
                end
            end
        end
    end
end);

addEventHandler('onClientResourceStop', resourceRoot, function()
    for i,v in pairs(inputs) do 
        destroyElement(v.base);
        destroyElement(v.outline);
    end
end);

--[[setTimer(function()
    addInput('teszt1', '', 'teszt', _, 400, 400, 300, 50, {14, 14, 14, 255}, {224, 104, 34, 255}, 1, _, 'center', 'center', false);
    addInput('teszt2', '', 'teszt', _, 400, 500, 300, 50, {14, 14, 14, 255}, {255, 0, 0, 255}, 0.45, _, 'center', 'center', false);
    addInput('teszt3', '', 'Súly', ' kg', 400, 600, 80, 40, {14, 14, 14, 255}, {224, 104, 34, 255}, 1, getFont('opensans', 12), 'center', 'center', true);
end, 2000, 1);]]