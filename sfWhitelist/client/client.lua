addEvent('whitelist:connection', true);
addEventHandler('whitelist:connection', root, function(success, name, notification, sound)
    if (sound) then 
        if (success) then 
            playSound('client/assets/sounds/success.wav');
        else 
            playSound('client/assets/sounds/failed.mp3');
        end
    end

    if (notifaction) then 
        if (success) then 
            createTrayNotification(name .. ' felcsatlakozott a szerverre! [SFRP]');
        end
    end
end);