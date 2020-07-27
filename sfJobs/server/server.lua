local jobs = {};

-- Events
addEvent('jobs:registerJob', true);
addEvent('jobs:forceSync', true);

-- Client - Server events
addEvent('jobs:requireJobs', true);

addEventHandler('onResourceStart', resourceRoot, function()
    for i,v in ipairs(config.jobpeds) do
        local x, y, z = unpack(v.position); 
        local ped = createPed(v.skin, x, y, z, v.rotation);
        setElementInterior(ped, v.interior);
        setElementDimension(ped, v.dimension);

        setElementData(ped, 'job >> ped', true);
        for _, data in ipairs(v.data) do 
            setElementData(ped, data[1], data[2]);
        end
    end 
end);

addEventHandler('jobs:registerJob', root, function(name, title, data)
    jobs[name] = {
        title = title,
        data = data,
        server = {},
    };
end);

addEventHandler('jobs:forceSync', root, function(entities)
    local tmpJobs = jobs;
    tmpJobs.server = nil;
    if (not entities) then 
        triggerClientEvent(root, 'jobs:syncJobsToClient', root, tmpJobs);
    else 
        if (type(entities) == 'table') then 
            for _, player in ipairs(entities) do 
                triggerClientEvent(player, 'jobs:syncJobsToClient', player, tmpJobs);
            end
        elseif (isElement(entities) and getElementType(entities) == 'player') then 
            triggerClientEvent(entities, 'jobs:syncJobsToClient', entities, tmpJobs);
        end
    end
end);

addEventHandler('jobs:requireJobs', root, function()
    local tmpJobs = jobs;
    tmpJobs.server = nil;
    triggerClientEvent(client, 'jobs:syncJobsToClient', client, tmpJobs);
end);