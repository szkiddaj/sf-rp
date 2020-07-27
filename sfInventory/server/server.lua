core = exports['sfCore'];
conn = core:getConnection();

Async:setPriority('low');

local actions = {};

addEventHandler('onResourceStart', resourceRoot, function()
    --[[ Játékos itemek betöltése ]]--
    Async:foreach(getElementsByType('player'), function(player)
        local charid = getElementData(player, 'character >> id');
        if (charid) then 
            dbQuery(function(qh)
                local result = dbPoll(qh, 10);
                if (result) then 
                    local inventory = {};
                    for _, data in ipairs(result) do 
                        inventory[data.slot] = {
                            itemid = data.itemid,
                            count = data.count,
                            value = data.value,
                            data = fromJSON(data.data),
                        };
                    end

                    setElementData(player, 'character >> inventory', inventory);
                end
            end, conn, 'SELECT * FROM items__player WHERE player = ?', charid);
        end
    end);
end);

function loadPlayerInventory(player)
    local charid = getElementData(player, 'character >> id');
    if (charid) then 
        dbQuery(function(qh)
            local result = dbPoll(qh, 10);
            if (result) then 
                local inventory = {};
                for _, data in ipairs(result) do 
                    inventory[data.slot] = {
                        itemid = data.itemid,
                        count = data.count,
                        value = data.value,
                        data = fromJSON(data.data),
                    };
                end

                setElementData(player, 'character >> inventory', inventory);
            end
        end, conn, 'SELECT * FROM items__player WHERE player = ?', charid);
    end
end

--[[ Alapvető inventory funkciók ]]--
addEvent('inventory:use', true);
addEventHandler('inventory:use', root, function(player, slot)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    if (inventory[slot]) then 
        if (items[inventory[slot].itemid].use) then 
            items[inventory[slot].itemid].use.func(player, slot, inventory[slot], unpack(items[inventory[slot].itemid].use.args));
        else 
            local itemid = inventory[slot].itemid;

            if (isStorageItem(itemid)) then -- Ha tároló cucc
                triggerClientEvent(player, 'inventory:openStorage', player, slot);
                return;
            end

            if (items[itemid].type == 'food') then 
                eat(items[itemid]);
                inventory[slot].count = inventory[slot].count - items[itemid].use.remove;
                if (inventory[slot].count <= 0) then 
                    inventory[slot] = nil;
                end
                return;
            end

            if (itemid == 10) then 
                print('ITEM HASZNÁLAT');
            elseif (itemid == 47) then 
                eat()
            else
                outputChatBox(core:getServerSyntax(_, 'Ehhez a tárgyhoz nem tartozik funkció!'), player, 255, 255, 255, true); 
            end
        end
    end
end);

addEvent('inventory:moveItem', true);
addEventHandler('inventory:moveItem', root, function(player, slot, data)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    if (inventory[slot] == nil) then 
        inventory[slot] = inventory[data.from];
        inventory[data.from] = nil;
        setElementData(player, 'character >> inventory', inventory);
    end 
end);

addEvent('inventory:stackItem', true);
addEventHandler('inventory:stackItem', root, function(player, slot, item)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    if (items[inventory[slot].itemid] and (items[inventory[slot].itemid].stackable or false) and items[item.item] and items[item.item].stackable and item.item == inventory[slot].itemid) then
        inventory[slot].count = inventory[slot].count + inventory[item.from].count;
        inventory[item.from] = nil;
        item = nil;
        setElementData(player, 'character >> inventory', inventory);
    end
end);

addEvent('inventory:putItemInStorage', true);
addEventHandler('inventory:putItemInStorage', root, function(player, storage, item, slot, storageSlot)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    if (not storageSlot) then 
        if (countEmptyStorageSlots(storage.data.items, items[storage.itemid].storage.slots) > 0) then 
            local emptyslot = findFirstEmptyStorageSlot(storage.data.items, items[storage.itemid].storage.slots);
            if (emptyslot) then -- Van hely a storage itemben
                print(slot);
                inventory[slot].data.items[emptyslot] = inventory[item.from];
                inventory[item.from] = nil;
                setElementData(player, 'character >> inventory', inventory);
                return;
            else 
                print('NEM')
            end 
        else 
            print('NINCS HELY!');
        end
    else 
        if (not storage.data.items[slot]) then 
            inventory[storageSlot].data.items[slot] = inventory[item.from];
            inventory[item.from] = nil;
            setElementData(player, 'character >> inventory', inventory);
            return;
        end
    end
end);

addEvent('inventory:moveItemInsideStorage', true);
addEventHandler('inventory:moveItemInsideStorage', root, function(player, item, storageSlot, slot)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    local storage = inventory[storageSlot].data.items;
    if (storage and not storage[slot]) then 
        inventory[storageSlot].data.items[slot] = storage[item.from];
        storage[item.from] = nil;
        setElementData(player, 'character >> inventory', inventory);
    end 
end);

addEvent('inventory:moveItemOutsideStorage', true);
addEventHandler('inventory:moveItemOutsideStorage', root, function(player, storagedata, storageslot, itemslot)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    if (not inventory[itemslot]) then 
        inventory[itemslot] = inventory[storageslot].data.items[storagedata.from];
        inventory[storageslot].data.items[storagedata.from] = nil;
        setElementData(player, 'character >> inventory', inventory);
    end 
end);

addEvent('inventory:stackItemOutsideStorage', true);
addEventHandler('inventory:stackItemOutsideStorage', root, function(player, storagedata, storageslot, itemslot)
    if (not getElementData(player, 'logged') or isPedDead(player)) then return; end
    if (isTimer(actions[player])) then return; end 
    actions[player] = setTimer(function() end, 200, 1);

    local inventory = getElementData(player, 'character >> inventory');
    if (inventory[itemslot]) then 
        if (inventory[itemslot].itemid and inventory[storageslot].data.items[storagedata.from].itemid and inventory[itemslot].itemid == inventory[storageslot].data.items[storagedata.from].itemid and inventory[itemslot].value == inventory[storageslot].data.items[storagedata.from].value) then 
            inventory[itemslot].count = inventory[itemslot].count + inventory[storageslot].data.items[storagedata.from].count;
            inventory[storageslot].data.items[storagedata.from] = nil;
            setElementData(player, 'character >> inventory', inventory);
        end
    end 
end);

addCommandHandler('teszt', function(player)
    iprint(hasPlayerItem(player, 1, 53, false))
end);