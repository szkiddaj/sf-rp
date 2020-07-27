local core = exports['sfCore'];
local conn = core:getConnection();
local colors = core:getAllColors();

local commands = {
    pos = { required = 1, noduty = 1 },
    setpos = { required = 3, noduty = 3 },

    setalevel = { required = 3, noduty = 3 },
    setaname = { required = 3, noduty = 3 },

    adminduty = { required = 1, noduty = 1 },
    fly = { required = 1, noduty = 3 },
    goto = { required = 1, noduty = 1 },
    gethere = { required = 1, noduty = 1 },
    aheal = { required = 2, noduty = 3 },
};


local adminSerialRequiredAbove = 2;
local adminSerials = {
    ['CEE672F40DCC8E733B3FE36B165FDEF3'] = true,
    ['9BB67196FE796846835536CBFF224224'] = true,
    ['CDABB06A2FE186A469DB4D114CA42C81'] = true,
};

local developerSerials = {
    ['CEE672F40DCC8E733B3FE36B165FDEF3'] = true,
    ['9BB67196FE796846835536CBFF224224'] = true,
};

--[[ Admin adás ellenőrzés ]]--

addEventHandler('onElementDataChange', root, function(key, old, new)
    if (getElementType(source) == 'player' and key == 'admin >> level') then 
        if (not adminSerials[getPlayerSerial(source)] and adminSerialRequiredAbove <= (tonumber(new) or 999)) then 
            adminMessage(core:getServerSyntax('Admin', (getElementData(source, 'character >> name') or getPlayerName(source)) .. ' nincs beleírva az engedélyezett adminok listájában, ezért az adminja el lett véve!'));
            setElementData(source, 'admin >> level', 0);
            setElementData(source, 'admin >> duty', false);
            dbExec(conn, 'UPDATE characters SET admin = ? WHERE account = ?', toJSON({ level = 0, name = 'Admin', stats = getElementData(source, 'admin >> stats')}), getElementData(source, 'account >> id'));
        end
    end
end);

--[[ Fejlesztői faszságok ]]--

addCommandHandler('pos', function(player, cmd)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    outputChatBox(core:getServerSyntax('Admin', 'Jelenlegi koordináta a vágólapra másolva!'), player, 255, 255, 255, true);

    local x, y, z = unpack({getElementPosition(player)});
    triggerClientEvent(player, 'admin:copy', player, x .. ', ' .. y .. ', ' .. z);
end);

addCommandHandler('setpos', function(player, cmd, x, y, z)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    if (not x or not y or not z) then 
        outputChatBox(core:getServerSyntax('Admin', 'Hiányzó paraméter!'), player, 255, 255, 255, true);
        return;
    end

    x = x:gsub(',', '');
    y = y:gsub(',', '');
    z = z:gsub(',', '');

    setElementPosition(player, tonumber(x), tonumber(y), tonumber(z));
end);

addCommandHandler('setalevel', function(player, cmd, target, level)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    if (target and level) then 
        target = core:findPlayer(target);
        if (target) then 
            if (getElementData(target, 'logged')) then 
                if (tonumber(level) and tonumber(level) <= (getElementData(player, 'admin >> level') or 0) or developerSerials[getPlayerSerial(player)]) then 
                    if (getElementData(player, 'admin >> level') > getElementData(target, 'admin >> level') or developerSerials[getPlayerSerial(player)]) then 
                        setElementData(target, 'admin >> duty', false);
                        setElementData(target, 'admin >> level', tonumber(level));
                        adminMessage(core:getServerSyntax('Admin', colors.server.hex .. (getElementData(player, 'admin >> name') or getPlayerName(player)) .. colors.white.hex .. ' beállította '..colors.server.hex..getElementData(target, 'character >> name')..colors.white.hex..' adminisztrátori szintjét '..colors.server.hex..core:getAdminTitle(tonumber(level))..colors.white.hex..'-ra/-re!'));
                        dbExec(conn, 'UPDATE characters SET admin = ? WHERE account = ?', toJSON({ level = tonumber(level), name = getElementData(target, 'admin >> name'), stats = getElementData(target, 'admin >> stats')}), getElementData(target, 'account >> id'));
                    else 
                        outputChatBox(core:getServerSyntax('Admin', 'Nálad nagyobb admin szintjét nem tudok megváltoztatni!'), player, 255, 255, 255, true);
                        outputChatBox(core:getServerSyntax('Admin', (getElementData(target, 'admin >> name') or getElementData(target, 'character >> name')) .. ' meg akarta változtatni az adminszintedet!'), target, 255, 255, 255, true);
                    end
                else 
                    outputChatBox(core:getServerSyntax('Admin', 'Nálad nagyobb adminisztrátori szintet nem tudsz adni!'), player, 255, 255, 255, true);
                end
            else 
                outputChatBox(core:getServerSyntax('Admin', 'A játékos nincs bejelentkezve!'), player, 255, 255, 255, true);
            end
        else 
            outputChatBox(core:getServerSyntax('Admin', 'Nem találtam a játékost!'), player, 255, 255, 255, true);
        end
    else 
        missingArguments(player, cmd, 'Játékos', 'Adminszint');
    end
end);

addCommandHandler('setaname', function(player, cmd, target, name)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    if (target and name) then 
        target = core:findPlayer(target);
        if (target) then 
            if (getElementData(target, 'logged')) then 
                setElementData(target, 'admin >> duty', false);
                setElementData(target, 'admin >> name', name);
                adminMessage(core:getServerSyntax('Admin', colors.server.hex..(getElementData(player, 'admin >> name') or getPlayerName(player)) .. colors.white.hex .. ' beállította '..colors.server.hex..getElementData(target, 'character >> name')..colors.white.hex..' adminisztrátori nevét '..colors.server.hex..name..colors.white.hex..'-ra/-re!'));
                dbExec(conn, 'UPDATE characters SET admin = ? WHERE account = ?', toJSON({ level = getElementData(target, 'admin >> level'), name = name, stats = getElementData(target, 'admin >> stats')}), getElementData(target, 'account >> id'));
            else 
                outputChatBox(core:getServerSyntax('Admin', 'A játékos nincs bejelentkezve!'), player, 255, 255, 255, true);
            end
        else 
            outputChatBox(core:getServerSyntax('Admin', 'Nem találtam a játékost!'), player, 255, 255, 255, true);
        end
    else 
        missingArguments(player, cmd, 'Játékos', 'Admin név');
    end
end);

--[[ Minden egyéb ]]--

addCommandHandler('adminduty', function(player, cmd)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    setElementData(player, 'admin >> duty', not (getElementData(player, 'admin >> duty') or false));
    if (getElementData(player, 'admin >> duty')) then 
        outputChatBox(core:getServerSyntax('Admin', getElementData(player, 'admin >> name') .. ' admin szolgálatba állt!'), root, 255, 255, 255, true);

        -- Majd ide még valami adminidő lófasz counter gecit kéne csinálni
    else
        outputChatBox(core:getServerSyntax('Admin', getElementData(player, 'admin >> name') .. ' kilépett az admin szolgálatból!'), root, 255, 255, 255, true);
    end
end);

addCommandHandler('fly', function(player, cmd)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    triggerClientEvent(player, 'admin:fly', player);
end);

addCommandHandler('goto', function(player, cmd, target)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    target = core:findPlayer(target);
    if (target) then 
        if (getElementData(target, 'logged')) then 
            iprint(target);
            outputChatBox(core:getServerSyntax('Admin', 'Ráteleportáltál ' .. colors.server.hex .. getElementData(target, 'character >> name') .. colors.white.hex .. '-ra/-re') .. '!', player, 255, 255, 255, true);
            outputChatBox(core:getServerSyntax('Admin', colors.server.hex .. getElementData(player, 'admin >> name') .. colors.white.hex .. ' rád teleportált!'), target, 255, 255, 255, true);
            setElementPosition(player, unpack({getElementPosition(target)}));
            setElementInterior(player, getElementInterior(target));
            setElementDimension(player, getElementDimension(target));
        else 
            outputChatBox(core:getServerSyntax('Admin', 'A játékos nincs bejelentkezve!'), player, 255, 255, 255, true);
        end
    else 
        missingArguments(player, cmd, 'Játékos')
    end
end);

addCommandHandler('gethere', function(player, cmd, target)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    target = core:findPlayer(target);
    if (target) then 
        if (getElementData(target, 'logged')) then 
            iprint(target);
            outputChatBox(core:getServerSyntax('Admin', 'Magadhoz teleportáltad ' .. colors.server.hex .. getElementData(target, 'character >> name') .. colors.white.hex .. '-t!'), player, 255, 255, 255, true);
            outputChatBox(core:getServerSyntax('Admin', colors.server.hex .. getElementData(player, 'admin >> name') .. colors.white.hex .. ' magához teleportált!'), target, 255, 255, 255, true);
            setElementPosition(target, unpack({getElementPosition(player)}));
            setElementInterior(target, getElementInterior(player));
            setElementDimension(target, getElementDimension(player));
        else 
            outputChatBox(core:getServerSyntax('Admin', 'A játékos nincs bejelentkezve!'), player, 255, 255, 255, true);
        end
    else 
        missingArguments(player, cmd, 'Játékos')
    end
end);

addCommandHandler('aheal', function(player, cmd, target)
    if (not hasPermission(player, cmd)) then 
        outputChatBox(core:getServerSyntax('Admin', 'Nincs elég jogosultságod hogy használni tudd a '..colors.server.hex..cmd..colors.white.hex..' parancsot!'), player, 255, 255, 255, true);
        return;
    end

    target = core:findPlayer(target);
    if (target) then 
        if (getElementData(target, 'logged')) then 
            outputChatBox(core:getServerSyntax('Admin', 'Meggyógyítottad ' .. colors.server.hex .. getElementData(target, 'character >> name') .. colors.white.hex .. '-t!'), player, 255, 255, 255, true);
            outputChatBox(core:getServerSyntax('Admin', colors.server.hex .. getElementData(player, 'admin >> name') .. colors.white.hex .. ' meggyógyított!'), target, 255, 255, 255, true);
            setElementHealth(target, 100);
            setElementData(target, 'character >> hunger', 100);
            setElementData(target, 'character >> thirst', 100);
        else 
            outputChatBox(core:getServerSyntax('Admin', 'A játékos nincs bejelentkezve!'), player, 255, 255, 255, true);
        end
    else 
        missingArguments(player, cmd, 'Játékos')
    end
end);

--[[ Minden egyéb lófasz ]]--

function missingArguments(player, cmd, ...)
    outputChatBox(core:getServerSyntax('Admin', '/'..cmd..colors.server.hex..' ['..table.concat({...}, '] [')..']'), player, 255, 255, 255, true);
end

function hasPermission(player, cmd)
    local level = tonumber(getElementData(player, 'admin >> level')) or 0;

    if (commands[cmd]) then 
        if (developerSerials[getPlayerSerial(player)]) then return true; end
        if (not getElementData(player, 'admin >> duty') or false) then
            return (commands[cmd].noduty and (commands[cmd].noduty <= level or false) or false);
        else 
            return (commands[cmd].required and (commands[cmd].required <= level or false) or false);
        end
    end 

    return false;
end 

function adminMessage(msg, level, needaduty)
    if (not level) then level = 1; end
    if (not needaduty) then needaduty = false; end

    for _, player in ipairs(getElementsByType('player')) do 
        if ((getElementData(player, 'admin >> level') or 0) >= level) then 
            outputChatBox(msg, player, 255, 255, 255, true);
        end
    end
end