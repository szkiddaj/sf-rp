local core = exports['sfCore'];
local enabledSerials = {
    ['CEE672F40DCC8E733B3FE36B165FDEF3'] = 'szkiddaj',
    ['9BB67196FE796846835536CBFF224224'] = 'Jani',
    ['CDABB06A2FE186A469DB4D114CA42C81'] = 'Toniel',
};

addEventHandler('onPlayerConnect', root, function(nick, address, _, serial)
    if (not enabledSerials[serial]) then 
        cancelEvent(true, 'Nem vagy az engedélyezett játékosok listáján! További információk az fb.com/sfrpghu oldalon olvashatsz!');

        fetchRemote('https://ipapi.co/'..address..'/json/', function(result)
            outputChatBox(core:getServerSyntax('Whitelist', nick:gsub('#%x%x%x%x%x%x', '') .. ' ('..fromJSON(result).city..') kickelve lett a szerverről, mert nincsen az engedélyezett játékosok listáján!'), root, 255, 255, 255, true);
        end);

        triggerClientEvent(root, 'whitelist:connection', root, false, nick, false, true);
    else 
        outputChatBox(core:getServerSyntax('Whitelist', nick:gsub('#%x%x%x%x%x%x', '') .. ' ('..enabledSerials[serial]..') felcsatlakozott a szerverre!'), root, 255, 255, 255, true);
        triggerClientEvent(root, 'whitelist:connection', root, true, nick, true, true);
    end
end);

addEventHandler('onResourceStart', resourceRoot, function()
    for _, player in ipairs(getElementsByType('player')) do 
        if (not enabledSerials[getPlayerSerial(player)]) then 
            outputChatBox(core:getServerSyntax('Whitelist', getPlayerName(player):gsub('#%x%x%x%x%x%x', '') .. ' kickelve lett a szerverről, mert nincsen az engedélyezett játékosok listáján!'), root, 255, 255, 255, true);
            kickPlayer(player, 'Rendszer', 'Nem vagy az engedélyezett játékosok listáján! További információk az fb.com/sfrpghu oldalon olvashatsz!');
        end
    end
end);