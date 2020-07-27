function debug(text, path, level, color) --[[ text = szöveg, path = Fájl helye, sor kiírása, level = outputDebugStringnél ilyen error lófaszt lehet megadni, color = szín (pl: {255, 255, 255}) ]]
    if (not data.debug) then return end
    if (not path) then path = false; end
    if (not level) then level = 0; end
    if (not color) then color = {255, 0, 0}; end
    if (path) then outputDebugString(text, level, unpack(color)) else print(text) end
end

function findPlayer(filter) --[[ Filter = Játékos ID vagy név(részlet)]]
    if (not filter) then return false; end

    if (tonumber(filter)) then
        filter = tonumber(filter); 
        for _, player in ipairs(getElementsByType('player')) do 
            if ((getElementData(player, 'player >> id') or -1) == filter) then 
                return player;
            end 
        end
    else 
        local name = string.lower(filter):gsub('_', ' '):gsub('#%x%x%x%x%x%x', '');
        for _, player in ipairs(getElementsByType('player')) do 
            local pname = string.lower((getElementData(player, 'player >> name') or getPlayerName(player))):gsub('_', ' '):gsub('#%x%x%x%x%x%x', '');
            if (pname:find(name, 1, true)) then 
                return player;
            end
        end
    end

    return false;
end