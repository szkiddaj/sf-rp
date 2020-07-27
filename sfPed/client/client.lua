addEventHandler('onClientPedDamage', root, function()
    if (getElementData(source, 'ped >> invincible')) then 
        cancelEvent();
    end
end);

addEventHandler('onClientPlayerStealthKill', root, function(target)
    if (getElementData(target, 'ped >> invincible')) then 
        cancelEvent();
    end
end);