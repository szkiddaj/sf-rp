local core = exports['sfCore'];
local conn = core:getConnection();

addEventHandler('onResourceStart', resourceRoot, function() 
    -- Összes kocsi betöltése

    dbQuery(function(qh)
        local result = dbPoll(qh, 10);
        Async:foreach(result, function(result)
            local x, y, z, rx, ry, rz, int, dim = unpack(fromJSON(result.position));
            local vehicle = createVehicle(result.model, x, y, z, rx, ry, rz);
            setElementInterior(vehicle, int);
            setElementDimension(vehicle, dim);

            setElementData(vehicle, 'vehicle >> locked', result.locked == 1);
            setVehicleLocked(vehicle, result.locked == 1);

            setElementData(vehicle, 'vehicle >> lights', result.lights);
            setVehicleOverrideLights(vehicle, result.lights);

            -- Szín beállítás

            local colors = fromJSON(result.colors);
            setVehicleColor(vehicle, unpack(colors.primary));

            -- Komponensek beállítása (Törések, stb)
            local components = fromJSON(result.components);
            for i,v in ipairs(components.panels) do 
                i = i - 1;
                iprint(i, v);
                setVehiclePanelState(vehicle, i, v);
            end

            for i,v in ipairs(components.lights) do 
                i = i - 1;
                iprint(i, v);
                setVehicleLightState(vehicle, i, v);
            end

            for i,v in ipairs(components.doors) do 
                i = i - 1;
                iprint(i, v);
                setVehicleDoorState(vehicle, i, v);
            end

            loadVehicle(vehicle);
        end);
    end, conn, 'SELECT * FROM vehicles');
end);

function loadVehicle(vehicle)
    setElementAlpha(vehicle, 100);
    setElementCollisionsEnabled(vehicle, false);

    setTimer(function()
        setElementAlpha(vehicle, 150);
        setTimer(function()
            setElementAlpha(vehicle, 200);
            setTimer(function()
                setElementAlpha(vehicle, 255);
                setElementCollisionsEnabled(vehicle, true);
            end, 1500, 1);
        end, 1500, 1);
    end, 1500, 1);
end