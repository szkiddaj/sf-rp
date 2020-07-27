local players = {};

print('indentity.lua elindult!');

addEventHandler('onPlayerJoin', root, function()
    for i = 1, 1024 do 
        if (not isElement(players[i])) then 
            players[i] = source;
            setElementData(source, 'player >> id', i);
            break;
        end
    end
end);

addEventHandler('onPlayerQuit', root, function()
    local id = getElementData(source, 'player >> id');
    if (players[id]) then 
        players[id] = nil;
    end
end);