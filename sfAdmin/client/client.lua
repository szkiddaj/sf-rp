addEvent('admin:copy', true);
addEventHandler('admin:copy', root, function(text)
    setClipboard(text);
end);

addEventHandler('onClientPlayerDamage', root, function()
    if (getElementData(source, 'admin >> duty')) then 
        cancelEvent();
    end
end);

addEventHandler('onClientPlayerStealthKill', root, function(target)
    if (getElementData(target, 'admin >> duty')) then 
        cancelEvent();
    end
end);