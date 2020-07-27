local objects = {
    {'cuntwland39b', 17110},
    {'cuntwroad68', 17279},
    {'cuntwroad71', 17281},
}

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i,v in ipairs(objects) do 
        engineReplaceModel(engineLoadDFF('assets/'..v[1]..'.dff'), v[2]);
        engineReplaceCOL(engineLoadCOL('assets/'..v[1]..'.col'), v[2]);
    end

    removeWorldModel(17002, 25, 53.7998046875, -1531.8955078125, 8.7500143051147);
end);