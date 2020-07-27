local checkboxes = {};

function addCheckbox(id, x, y, w, h, basecolor, hovercolor, tickcolor, active, radius, fontsize)
    checkboxes[id] = { 
        x = x, 
        y = y, 
        w = w, 
        h = h, 
        basecolor = basecolor, 
        hovercolor = hovercolor, 
        progress = 0,
        shader = dxCreateShader(requestRoundRectangleShader(false)),
        tickcolor = tickcolor or tocolor(0, 255, 0), 
        active = active or false,
        onclick = {},
        fontsize = fontsize or 11,
    };

    dxSetShaderValue(checkboxes[id].shader, 'color', {basecolor[1] / 255, basecolor[2] / 255, basecolor[3] / 255, basecolor[4] / 255});
    dxSetShaderValue(checkboxes[id].shader, 'radius', {radius, radius, radius, radius});
end

function destroyCheckbox(id)
    if (checkboxes[id]) then 
        print('ASD2');
        checkboxes[id] = nil;
    end
end

function setCheckboxProperty(id, prop, value)
    if (checkboxes[id]) then 
        checkboxes[id][prop] = value;
    end
end

addEventHandler('onClientRender', root, function()
    for i,v in pairs(checkboxes) do 
        if (cursorInZone(v.x, v.y, v.w, v.h)) then 
            if (v.progress < 0.9) then 
                v.progress = v.progress + 0.05;
            end
        else 
            if (v.progress > 0.05) then 
                v.progress = v.progress - 0.05;
            end
        end

        local color = {interpolateBetween(v.basecolor[1], v.basecolor[2], v.basecolor[3], v.hovercolor[1], v.hovercolor[2], v.hovercolor[3], v.progress, 'Linear')};
        dxDrawImage(v.x, v.y, v.w, v.h, v.shader, 0, 0, 0, _, true);
        dxSetShaderValue(v.shader, 'color', {color[1] / 255, color[2] / 255, color[3] / 255, v.basecolor[4]});
        if (v.active) then dxDrawText('', v.x, v.y, v.x + v.w, v.y + v.h, v.tickcolor, 1, getFont('fa', v.fontsize), 'center', 'center', true, false, true); end
    end
end);

addEventHandler('onClientClick', root, function(button, state)
    if (button == 'left' and state == 'down') then 
        for i,v in pairs(checkboxes) do 
            print(i);
            if (cursorInZone(v.x, v.y, v.w, v.h)) then 
                v.active = not v.active;
                triggerEvent('onCheckboxClick', root, i, v.active);
            end
        end
    end
end);

addEvent('onCheckboxClick');