setTimer(function()
    if (getElementData(localPlayer, 'logged') and not getElementData(localPlayer, 'admin >> duty')) then 
        setElementData(localPlayer, 'character >> hunger', getElementData(localPlayer, 'character >> hunger') - math.random(1, 2));
        setElementData(localPlayer, 'character >> thirst', getElementData(localPlayer, 'character >> thirst') - math.random(2, 3));

        if ((getElementData(localPlayer, 'character >> thirst') or 0) <= 0 or (getElementData(localPlayer, 'character >> hunger') or 0) <= 0) then 
            setElementHealth(localPlayer, getElementHealth(localPlayer) - 4);
        end
    end
end, 60000 * 3, 0);