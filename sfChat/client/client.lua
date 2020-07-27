local core = exports['sfCore'];
local colors = core:getAllColors();
local font = core:getFont('opensans', 11);

local labels = {};

addEvent('chat:label', true);
addEventHandler('chat:label', root, function(element, text, color)
    if (not labels[element]) then 
        labels[element] = {};
    end

    table.insert(labels[element], 1, {
        text = text,
        color = color,
        tick = getTickCount(),
        width = dxGetTextWidth(text, 1, font),
        index = #labels[element] + 1,
    });
end);

addEventHandler('onClientRender', root, function()
    local x, y, z = getElementPosition(localPlayer);

    for player, data in pairs(labels) do 
        local px, py, pz = getElementPosition(player);
        local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz);
        if (dist < 10) then 
            for i, v in ipairs(data) do 
                if (v.tick + (v.width * 20) < getTickCount()) then table.remove(labels[player], i) end

                i = i - 1;
                local hx, hy, hz = getPedBonePosition(player, 8);
                local sx, sy = getScreenFromWorldPosition(hx, hy, hz + 0.3);
                if (sx and sy) then 
                    local width = dxGetTextWidth(v.text, 1, font);
                    core:dxDrawRoundedRectangle(sx - v.width / 2 - 4, sy - (i * 30), v.width + 8, 28, colors.grey1.tocolor, 6);
                    dxDrawText(v.text, sx, sy + 28 / 2 - (i * 30), _, _, v.color, 1, font, 'center', 'center');
                end
            end
        end
    end
end);

-- /placedo

local font2 = core:getFont('opensans', 13);
local font3 = core:getFont('opensans', 10);
local font4 = core:getFont('fa', 13);
local places = {};

addEvent('placedo:sync', true);
addEventHandler('placedo:sync', root, function(data)
    places = data;
end);

addEventHandler('onClientRender', root, function()
    for player, data in pairs(places) do 
        for i, v in ipairs(data) do 
            local x, y, z = getElementPosition(localPlayer);
            local px, py, pz = unpack(v.position);
            local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz);
            if (dist < 10) then 
                local bx, by, bz = getPedBonePosition(localPlayer, 8);
                local sx, sy = getScreenFromWorldPosition(px, py, pz);
                if (sx and sy) then 
                    dxDrawText(v.text .. ' ((' .. v.player .. '))', sx, sy, _, _, tocolor(0, 0, 0), 1, font2, 'center', 'center');
                    dxDrawText(v.text .. ' ((' .. v.player .. '))', sx + 1, sy + 1, _, _, tocolor(222, 64, 64), 1, font2, 'center', 'center');
                    dxDrawText('(( ' .. v.date .. ' ))', sx, sy + 20, _, _, tocolor(0, 0, 0), 1, font3, 'center', 'center');
                    dxDrawText('(( ' .. v.date .. ' ))', sx + 1, sy + 20 + 1, _, _, tocolor(222, 64, 64), 1, font3, 'center', 'center');

                    if (v.element == localPlayer or getElementData(localPlayer, 'admin >> duty')) then 
                        dxDrawText('', sx, sy + 40, _, _, tocolor(0, 0, 0), 1, font4, 'center', 'center');
                        dxDrawText('', sx + 1, sy + 40 + 1, _, _, tocolor(222, 64, 64), 1, font4, 'center', 'center');
                    end
                end
            end
        end
    end
end);

addEventHandler('onClientClick', root, function(button, state)
    if (button == 'left' and state == 'up') then 
        for player, data in pairs(places) do 
            for i, v in ipairs(data) do 
                local x, y, z = getElementPosition(localPlayer);
                local px, py, pz = unpack(v.position);
                local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz);
                if (dist < 10) then 
                    local sx, sy = getScreenFromWorldPosition(px, py, pz);
                    if (sx and sy) then 
                        if (v.element == localPlayer or getElementData(localPlayer, 'admin >> duty') and core:cursorInZone(sx - 10, sy + 30, 20, 20)) then 
                            triggerServerEvent('placedo:remove', localPlayer, player, i);
                        end
                    end
                end
            end
        end
    end
end);

-- Egyéb
addCommandHandler('clearchat', function()
    if (not getElementData(localPlayer, 'logged')) then return; end
    for i = 1, getChatboxLayout().chat_lines do 
        outputChatBox(' ');
    end
end);