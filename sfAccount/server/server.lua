local core = exports['sfCore'];
local conn = core:getConnection();

local salt = 'mateautista';

addEvent('account:clientLoaded', true);
addEventHandler('account:clientLoaded', root, function(player)
    dbQuery(function(qh)
        local result = dbPoll(qh, 10);
        if (result and #result > 0) then
            result = result[1];
            result = {result.id, result.admin, result.character, result.serial, result.bandate, result.expiredate, result.reason};
            triggerClientEvent(player, 'account:banResponse', player, true, result);
            return;
        end

        triggerClientEvent(player, 'account:banResponse', player, false);
    end, conn, 'SELECT * FROM bans WHERE serial = ? AND expiredate > NOW() LIMIT 1', getPlayerSerial(player));
end);

addEvent('account:login', true);
addEventHandler('account:login', root, function(player, username, password)
    local serial = getPlayerSerial(player);
    password = hashPassword(password);

    dbQuery(function(qh)
        local result = dbPoll(qh, 10);
        if (result and result[1]) then 
            result = result[1];

            if (result.serial ~= serial) then 
                core:debug('Ez a felhasználó nem ehhez az azonosítóhoz van társítva!');
                return;
            end

            setElementData(player, 'account >> id', result.id);
            setElementData(player, 'account >> username', result.username);

            dbQuery(function(qh)
                local result = dbPoll(qh, 10);
                if (result and result[1]) then
                    result = result[1];

                    setElementData(player, 'character >> id', result.id);

                    local pos = fromJSON(result.position);
                    spawnPlayer(player, pos[1], pos[2], pos[3], pos[4], result.skin, pos[5], pos[6]);

                    local stats = fromJSON(result.stats);
                    setElementHealth(player, stats[1] or 100);
                    setElementData(player, 'character >> hunger', stats[2] or 100);
                    setElementData(player, 'character >> thirst', stats[3] or 100);

                    local name = result.name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end):gsub('_', ' ');
                    setElementData(player, 'character >> name', name);
                    setElementData(player, 'character >> money', result.money);
                    setElementData(player, 'character >> description', result.description);

                    local admin = fromJSON(result.admin);
                    setElementData(player, 'admin >> level', tonumber(admin.level) or 0);
                    setElementData(player, 'admin >> name', tonumber(admin.name) or 'Admin');
                    setElementData(player, 'admin >> stats', admin.stats);
                    for name, value in pairs(admin.stats) do 
                        setElementData(player, 'admin >> stat >> ' .. name, value or 0);
                    end

                    triggerClientEvent(player, 'account:logged', player, true);

                    exports['sfInventory']:loadPlayerInventory(player);
                else 
                    core:debug('Nincs felhasználója'); 
                    triggerClientEvent(player, 'account:logged', player, false);
                end
            end, conn, 'SELECT * FROM characters WHERE account = ?', result.id);
        else 
            core:debug('Hibás felhasználónév vagy jelszó!');
        end
    end, conn, 'SELECT * FROM users WHERE username = ? AND password = ? LIMIT 1', username, password);
end);

addEvent('account:register', true);
addEventHandler('account:register', root, function(player, username, email, password)
    local serial = getPlayerSerial(player);
    password = hashPassword(password);

    dbQuery(function(qh)
        local result = dbPoll(qh, 10);
        if (result) then 
            local allowed = true;
            local msg = '';
            for i,v in ipairs(result) do 
                if (v.username == username) then 
                    allowed = false;
                    msg = 'Ez a felhasználónév már foglalt!';
                    break;
                end

                if (v.email == email) then 
                    allowed = false;
                    msg = 'Erre az emailre már van társítva egy felhasználó!';
                    break;
                end

                if (v.serial == serial) then 
                    allowed = false;
                    msg = 'Ehhez az azonosítóhoz már van társítva felhasználó!';
                    break;
                end
            end

            if (not allowed) then 
                core:debug(msg);
                return;
            end
            
            if (dbExec(conn, 'INSERT INTO users (username, email, password, serial) VALUES (?, ?, ?, ?)', username, email, password, serial)) then 
                core:debug('Sikeres regisztráció!');
            end
        end
    end, conn, 'SELECT * FROM users');
end);

addEvent('account:characterCreation', true);
addEventHandler('account:characterCreation', root, function(player, name, city, age, weight, height, gender, skin)

    local name = string.lower(name):gsub(' ', '_');

    dbQuery(function(qh)
        local result = dbPoll(qh, 10);
        if (result and result[1]) then 
            core:debug('Ez a karakternév foglalt!');
            return;
        end

        if (dbExec(conn, 'INSERT INTO characters (account, name, skin, description) VALUES (?, ?, ?, ?)', getElementData(player, 'account >> id'), name, skin, toJSON({city, age, weight, height, gender}))) then 
            core:debug('Sikeres karakter létrehozás!');
            triggerClientEvent(player, 'account:characterCreated', player);
        end
    end, conn, 'SELECT * FROM characters WHERE name = ? LIMIT 1', name);
end);

function savePlayer(player)
    local serial = getPlayerSerial(player);
    if (serial and (getElementData(player, 'logged') or false)) then
        local x, y, z = getElementPosition(player);
        local _, _, rot = getElementRotation(player);
        local int, dim = getElementInterior(player), getElementDimension(player);
        local position = toJSON({x, y, z, rot, int, dim});
        local stats = toJSON({getElementHealth(player), getElementData(player, 'character >> hunger') or 0, getElementData(player, 'character >> thirst') or 0});
        
        dbExec(conn, 'UPDATE characters SET position = ?, stats = ?', position, stats);

        core:debug(getPlayerName(player) .. ' játékos adatai mentve!');
    end
end

addCommandHandler('save', function(player) savePlayer(player); end);

function hashPassword(password)
    return sha256(salt..password..salt..password);
end