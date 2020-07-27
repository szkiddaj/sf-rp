local core = exports['sfCore'];

local loadedmods = {
    vehicles = {},
    skins = {},
};

addEventHandler('onClientResourceStart', resourceRoot, function()
    local file = xmlLoadFile('client/save.xml');
    if (not file) then 
        file = xmlCreateFile('client/save.xml', 'mods');
        -- Járművek
        local vehicles = xmlCreateChild(file, 'vehicles');

        for id, vehicle in pairs(mods.vehicles) do 
            local node = xmlCreateChild(vehicles, string.lower(getVehicleNameFromModel(id)):gsub(' ', ''));

            for setting, value in pairs(vehicle) do
                xmlNodeSetValue(xmlCreateChild(node, setting), (value and 1 or 0));
            end
        end

        xmlSaveFile(file);
        xmlUnloadFile(file);
    end

    local loaded = 0;

    local vehicles = xmlFindChild(file, 'vehicles', 0);
    for id, vehicle in pairs(mods.vehicles) do 
        local vehicle = xmlFindChild(vehicles, string.lower(getVehicleNameFromModel(id)):gsub(' ', ''), 0);
        local start = xmlNodeGetValue(xmlFindChild(vehicle, 'start', 0));
        local download = xmlNodeGetValue(xmlFindChild(vehicle, 'download', 0));
        if (start == '1') then 
            loadVehicle(id);
            loaded = loaded + 1;
        end 
    end

    core:debug('Betöltve ' .. loaded .. ' mod!');
end);

function unloadVehicle(id)
end

function loadVehicle(id)
    engineImportTXD(engineLoadTXD('client/assets/vehicles/'..id..'.txd'), id);
    engineReplaceModel(engineLoadDFF('client/assets/vehicles/'..id..'.dff'), id);
end