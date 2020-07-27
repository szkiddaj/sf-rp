addEvent('scoreboard:getMaxClients', true);
addEventHandler('scoreboard:getMaxClients', root, function(player) 
    triggerClientEvent(player, 'scoreboard:maxClients', player, getMaxPlayers()); 
end);