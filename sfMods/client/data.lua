mods = {
    vehicles = {
        [451] = { download = true, start = true },
        [596] = { download = true, start = true },
    },
};

vehicleNames = {
    [451] = 'Ford GT',
    [596] = 'rendorkocsi'
};

function getVehicleName(id)
    return (vehicleNames[id] or 'Ismeretlen');
end