local core = exports['sfCore'];
local admin = exports['sfAdmin'];
local conn = core:getConnection();

addEventHandler('onResourceStart', resourceRoot, function()
    dbQuery(function(qh)
        local result = dbPoll(qh, 10);
        Async:foreach(result, function(data)
            local x, y, z, rot, int, dim = unpack(fromJSON(data.position));
            local ped = createPed(data.skin, x, y, z, rot);

            setElementInterior(ped, int);
            setElementDimension(ped, dim);
            setElementFrozen(ped, true);

            setElementData(ped, 'ped >> invincible', true);
            setElementData(ped, 'ped >> type', data.type);
            setElementData(ped, 'ped >> name', data.name);
            setElementData(ped, 'ped >> label', data.label);

            triggerEvent('ped:add', root, ped, data.type);
        end);
    end, conn, 'SELECT * FROM peds');
end);

addCommandHandler('createped', function(player, cmd, type, name, ...)
    if (not admin:hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    if (type and name and (...)) then 
    end
end);

addEvent('ped:add', true);