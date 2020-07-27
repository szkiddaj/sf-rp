local buttons = {};

function addButton(id, text, x, y, w, h, basecolor, hovercolor, font, radius)
    radius = radius or 1;
    buttons[id] = {
        text = text,
        x = x, 
        y = y,
        w = w, 
        h = h,
        base = dxCreateShader(requestRoundRectangleShader(false)),
        color = {
            basecolor = basecolor,
            hovercolor = hovercolor,
            progress = 0,
        },
        font = font or getFont('opensans', 12),
        rounded = rounded or false,
        radius = radius or 2,
        onclick = {},
    };

    dxSetShaderValue(buttons[id].base, 'color', {basecolor[1] / 255, basecolor[2] / 255, basecolor[3] / 255, basecolor[4] / 255});
    dxSetShaderValue(buttons[id].base, 'radius', {radius, radius, radius, radius});
end

function destroyButton(id)
    if (buttons[id]) then 
        destroyElement(buttons[id].base);
        buttons[id] = nil;
    end
end

function clickButton(id, callback)
    if (buttons[id]) then 
        print('callback2: ' .. callback);
        table.insert(buttons[id].onclick, callback);
    end
end 

addEventHandler('onClientRender', root, function()
    for i,v in pairs(buttons) do 
        if (cursorInZone(v.x, v.y, v.w, v.h)) then 
            if (v.color.progress < 0.9) then 
                v.color.progress = v.color.progress + 0.05;
            end
        else 
            if (v.color.progress > 0.05) then 
                v.color.progress = v.color.progress - 0.05;
            end
        end

        local color = {interpolateBetween(v.color.basecolor[1], v.color.basecolor[2], v.color.basecolor[3], v.color.hovercolor[1], v.color.hovercolor[2], v.color.hovercolor[3], v.color.progress, 'Linear')};
        dxSetShaderValue(v.base, 'color', {color[1] / 255, color[2] / 255, color[3] / 255, v.color.basecolor[4] / 255});
        dxDrawImage(v.x, v.y, v.w, v.h, v.base, 0, 0, 0, _, true);
        dxDrawText(v.text, v.x, v.y, v.x + v.w, v.y + v.h, tocolor(255, 255, 255), 1, v.font, 'center', 'center', true, false, true);
    end
end);

addEventHandler('onClientClick', root, function(button, state)
    if (button == 'left' and state == 'up') then 
        for i,v in pairs(buttons) do 
            if (cursorInZone(v.x, v.y, v.w, v.h)) then 
                debug('MEGKATTINTVA: '..i);
                triggerEvent('onButtonClick', root, i);
            end
        end
    end
end);

--[[setTimer(function()
    addButton('id', 'teszt', 800, 500, 200, 40, {14, 14, 14, 255}, {224, 104, 34, 255}, true, 2);
end, 1000, 1);]]

addEvent('onButtonClick');