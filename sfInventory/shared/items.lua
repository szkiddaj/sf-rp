items = {
    [1] = {
        name = 'Lakáskulcs',
        weight = 0.1,
        type = 'key',
        stackable = false,
        storage = false,
        use = {
            func = triggerEvent,
            args = {'item:eat', root},
        },
    },
    [3] = {
        name = '9mm lőszer',
        weight = 0.02,
        type = 'ammo',
        stackable = true,
        storage = false,
    },
    [10] = {
        name = 'Kulcstartó',
        weight = 0.01,
        type = 'storage',
        stackable = false,
        storage = {
            slots = 12,
            maxweight = 1,
            allowedItems = {1},
        },
    },
    [47] = {
        name = 'Szendvics',
        weight = 0.2,
        type = 'food',
        stackable = false,
        use = {
            func = eat,
            args = {self},
            remove = 1,
            value = 20,
        },
    }
};

function isFood(itemid)
    return (items[itemid].type == 'food' and true or false);
end

function isDrink(itemid)
    return (items[itemid].type == 'drink' and true or false);
end

function isStorageItem(itemid)
    return (items[itemid].storage and true or false);
end

function getStorageItems()
    local ids = {};
    for i,v in pairs(items) do 
        if (isStorageItem(i)) then table.insert(ids, i); end
    end
    return ids;
end

function hasPlayerItem(player, item, value, includeStorage)
    if (not item) then return false; end
    if (includeStorage == nil) then includeStorage = true; end
    local inventory = getElementData(player, 'character >> inventory') or {};
    for i,v in pairs(inventory) do 
        if (not isStorageItem(v.itemid)) then 
            if (item == v.itemid) then 
                if (not value) then return true; end 
                if (value and value == v.value) then return true; end
            end
        else 
            if (includeStorage) then 
                for _, sv in pairs(v.data.items) do 
                    if (item == v.itemid) then 
                        if (not value) then return true; end 
                        if (value and value == v.value) then return true; end
                    end
                end
            end
        end
    end

    return false;
end