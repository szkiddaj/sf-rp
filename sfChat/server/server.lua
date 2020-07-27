local core = exports['sfCore'];
local colors = core:getAllColors();

-- Alap cuccok
addEventHandler('onPlayerChat', root, function(msg, msgType)
    cancelEvent();
    if (not getElementData(source, 'logged')) then return; end
    if (msgType == 2) then return; end

    if (msgType == 0) then -- Sima beszéd
        elementSayMessage(source, msg, 15);
    elseif (msgType == 1) then 
        elementMeMessage(source, msg, 10);
    end
end);

addCommandHandler('s', function(source, cmd, ...)
    if (not getElementData(source, 'logged')) then return; end
    local msg = table.concat({...}, ' ');

    elementSayMessage(source, msg, 30);
end);

addCommandHandler('c', function(source, cmd, ...)
    if (not getElementData(source, 'logged')) then return; end
    local msg = table.concat({...}, ' ');

    elementSayMessage(source, msg, 4.5);
end);

addCommandHandler('do', function(source, cmd, ...)
    if (not getElementData(source, 'logged')) then return; end
    elementDoMessage(source, table.concat({...}, ' '), 10);
end);

addCommandHandler('megprobal', function(source, cmd, ...)
    if (not getElementData(source, 'logged')) then return; end

    elementTryMessage(source, table.concat({...}, ' '), 10);
end);

function elementSayMessage(element, text, range)
    if (not range) then range = 10; end
    local name = ((getElementType(element) == 'player') and getElementData(element, 'character >> name') or getElementData(element, 'ped >> name'));
    local vehicle = getPedOccupiedVehicle(element);
    local type = ((range > 25) and 'ordítja' or ((range < 5) and 'suttogja' or 'mondja'));

    for player, distance in pairs(getPlayersInRange(element, range)) do 
        local r, g, b = interpolateBetween(255, 255, 255, 50, 50, 50, distance / range, 'Linear');
        if (not vehicle) then 
            outputChatBox(name .. ' ' .. type .. ': ' .. text, player, r, g, b, true);
            triggerClientEvent(player, 'chat:label', player, element, text, tocolor(255, 255, 255));
        else 
            if (vehicle == getPedOccupiedVehicle(player)) then 
                outputChatBox(name .. ' ' .. type .. ': ' .. text, player, r, g, b, true);
                triggerClientEvent(player, 'chat:label', player, element, text, tocolor(255, 255, 255));
            end
        end
    end
end

function elementMeMessage(element, text, range)
    if (not range) then range = 10; end
    local name = ((getElementType(element) == 'player') and getElementData(element, 'character >> name') or getElementData(element, 'ped >> name'));

    for player, distance in pairs(getPlayersInRange(element, range)) do 
        outputChatBox('*** ' .. name .. ' ' .. text, player, 191, 107, 181, true);
    end
end

function elementDoMessage(element, text, range)
    if (not range) then range = 10; end
    local name = ((getElementType(element) == 'player') and getElementData(element, 'character >> name') or getElementData(element, 'ped >> name'));

    for player, distance in pairs(getPlayersInRange(element, range)) do 
        outputChatBox('* ' .. text .. ' ((' .. name .. '))', player, 222, 64, 64, true);
    end
end

function elementTryMessage(element, text, range)
    if (not range) then range = 10; end
    local name = ((getElementType(element) == 'player') and getElementData(element, 'character >> name') or getElementData(element, 'ped >> name'));

    local result = (math.random(1, 2) == 1);
    local ending = (result and 'és sikerül neki!' or 'nem sikerül neki.');
    for player, distance in pairs(getPlayersInRange(element, range)) do 
        outputChatBox('** ' .. name .. ' megpróbál ' .. text .. ' ' .. ending, player, 217, 188, 46, true);
    end
    return result;
end

-- Placedo
local places = {};

addCommandHandler('placedo', function(player, cmd, ...)
    if (not getElementData(player, 'logged')) then return; end

    if (not places[player]) then 
        places[player] = {};
    end

    if (#places[player] > 5) then 
        print('VAN');
        repeat 
            table.remove(places[player], 1);
        until (places[player][5] ~= nil);
    end

    local time = getRealTime();

    table.insert(places[player], {
        element = player,
        player = getElementData(player, 'character >> name'),
        position = {getElementPosition(player)},
        text = table.concat({...}, ' '),
        date = string.format('%04d.%02d.%02d %02d:%02d:%02d', time.year + 1900, time.month + 1, time.monthday, time.hour, time.minute, time.second),
    });

    triggerClientEvent(root, 'placedo:sync', root, places);
end);

addEvent('placedo:remove', true);
addEventHandler('placedo:remove', root, function(player, index)
    if (places[player][index]) then 
        table.remove(places[player], index);
        triggerClientEvent(root, 'placedo:sync', root, places);
    end
end);

addEventHandler('onPlayerQuit', root, function()
    if (places[source]) then 
        places[source] = nil;
        triggerClientEvent(root, 'placedo:sync', root, places);
    end
end);

-- Egyéb
function getPlayersInRange(source, range)
    local players = {};
    local x, y, z = getElementPosition(source);
    for _, player in ipairs(getElementsByType('player')) do 
        local px, py, pz = getElementPosition(player);
        local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz);
        if (dist < tonumber(range)) then 
            players[player] = dist;
        end
    end
    return players;
end

function rgb2hex(r, g, b) 
    return string.format("#%02X%02X%02X", r, g, b) 
end 