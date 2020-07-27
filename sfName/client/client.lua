local core = exports['sfCore'];
local colors = core:getAllColors();
local font = core:getFont('opensansbold', 12);
local adminTitles = core:getAdminTitles();

local showLocal = false;
local elements = {};

local elementdatas = {
    ['admin >> duty'] = true,
    ['admin >> name'] = true,
    ['admin >> visible'] = true,
};

addEventHandler('onClientResourceStart', resourceRoot, function()
    for _, player in ipairs(getElementsByType('player', _, true)) do 
        loadElement(player);
    end

    for _, ped in ipairs(getElementsByType('ped', _, true)) do 
        loadElement(ped);
    end
end);

addEventHandler('onClientElementStreamIn', root, function()
    if (not elements[source]) then 
        loadElement(source);
    end
end);

addEventHandler('onClientElementStreamOut', root, function()
    if (elements[source]) then 
        elements[source] = nil;
    end
end);

addEventHandler('onClientElementDestroy', root, function()
    if (elements[source]) then 
        elements[source] = nil;
    end
end);

addEventHandler('onClientElementDataChange', root, function(key)
    if (not getElementData(source, 'logged')) then return; end 
    if (not isElementStreamedIn(source)) then return; end 
    if (elementdatas[key]) then 
        loadElement(source);
    end
end);

function loadElement(element)
    if (getElementType(element) == 'player') then 
        if (not getElementData(element, 'logged')) then return; end
        setPlayerNametagShowing(element, false);

        elements[element] = {
            id = getElementData(element, 'player >> id'),
            name = getElementData(element, 'character >> name'),

            aduty = getElementData(element, 'admin >> duty'),
            aname = getElementData(element, 'admin >> name'),
            alevel = getElementData(element, 'admin >> level'),
        };
    elseif (getElementType(element) == 'ped') then 
        elements[element] = {
            name = getElementData(element, 'ped >> name'),
            label = getElementData(element, 'ped >> label'),
        };
    end
end

addEventHandler('onClientRender', root, function()
    local x, y, z = getElementPosition(localPlayer);
    for elem, data in pairs(elements) do 
        if (elem and (elem ~= localPlayer and true or (showLocal and true or false))) then 
            local px, py, pz = getPedBonePosition(elem, 8);
            local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz);
            if (dist < 15) then 
                local sx, sy = getScreenFromWorldPosition(px, py, pz + 0.35);
                local alpha = interpolateBetween(255, 0, 0, 0, 0, 0, dist / 15, 'Linear');
                if (sx and sy) then 
                    local name = (data.aduty and data.aname or data.name) .. colors.server.hex .. ' (' .. (data.id and data.id or data.label) .. ') ' .. (data.aduty and '('..core:getAdminTitle(data.alevel)..')' or '');
                    dxDrawText(name:gsub('#%x%x%x%x%x%x', ''), sx + 1, sy + 1, _, _, tocolor(0, 0, 0, alpha), 1, font, 'center', 'center', _, _, _, true);
                    dxDrawText(name, sx, sy, _, _, tocolor(255, 255, 255, alpha), 1, font, 'center', 'center', _, _, _, true);
                end
            end
        end
    end
end);

addCommandHandler('showtag', function()
    showLocal = not showLocal;
    outputChatBox(core:getServerSyntax('Nametag', (showLocal and 'Bekapcsoltad a saját nametagedet!' or 'Kikapcsoltad a saját nametagedet!')), 0, 0, 0, true);
end);