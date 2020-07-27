local fonts = {};
local fontLocations = {
    opensans = { path = 'OpenSans-Regular.ttf', min = 5, max = 50 },
    opensansbold = { path = 'OpenSans-ExtraBold.ttf', min = 5, max = 50 },
    fa = { path = 'fontawesome.otf', min = 6, max = 40 },
};

addEventHandler('onClientResourceStart', resourceRoot, function()
    debug('[Core]: Fontok betöltése..', true, 0, {255, 255, 255});
    
    local count = 0;
    local tick = getTickCount();
    for name, options in pairs(fontLocations) do 
        for size = options.min, options.max do 
            fonts[name..size] = dxCreateFont('client/assets/fonts/'..options.path, size);
        end
        debug('[Core]: ' .. name .. ' font betöltve!', true, 0, {255, 255, 255});

        count = count + 1;
    end

    debug('[Core]: Fontok betöltve! ('..count..' font, ' .. getTickCount() - tick .. ' ms)', true, 0, {255, 255, 255});
end);

function getFont(font, size)
    return (fonts[font..size] or false);
end