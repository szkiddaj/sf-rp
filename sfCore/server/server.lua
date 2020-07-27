addEventHandler('onResourceStart', resourceRoot, function()
    setGameType(data.gametype);
    setMapName(data.mapname);
    setMaxPlayers(data.maxslot);
    --setFPSLimit(data.fps);
end);