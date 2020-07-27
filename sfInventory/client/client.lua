core = exports['sfCore'];
interface = exports['sfInterface'];
colors = core:getAllColors();

local sx, sy = guiGetScreenSize();
local px, py = 450, 256;
local x, y = sx/2-px/2,sy/2-py/2;

local render = false;

local moveItem;
local storageMoveItem;

local logo = dxCreateTexture('client/assets/images/logo.png');

local itemImages = {};

local renderStorage = false;
local storageItemSlot;

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i = 1, 130 do 
        if (fileExists('client/assets/items/'..i..'.png')) then 
            itemImages[i] = dxCreateTexture('client/assets/items/'..i..'.png');
        end
    end
end);

addEventHandler('onClientKey', root, function(key, press)
    if (isChatBoxInputActive()) then return; end

    if (key == 'i' and press) then 
        if (not render) then 
            addEventHandler('onClientRender', root, renderInventory);
            addEventHandler('onClientClick', root, clickInventory);
            render = true;
        else 
            closeInventory();
        end
    end
end);

function renderInventory()
    if (not getElementData(localPlayer, 'logged') or isPedDead(localPlayer)) then closeInventory(); return; end
    dxDrawRectangle(x, y, px, py, colors.grey1.tocolor);

    local playerItems = getElementData(localPlayer, 'character >> inventory') or {};

    --[[ Itemek renderelése (1-32 slotig vannak az itemek) ]]--
    local columns = 0;
    local rows = 0;
    for i = 1, 32 do 
        if (columns >= 8) then 
            columns = 0;
            rows = rows + 1;
        end

        --[[ Inventory slotok hattere ]]--
        local color = colors.grey2.tocolor;
        if (core:cursorInZone(x + 6 + (columns * 44), y + 40 + (rows * 44), 40, 40)) then 
            color = colors.server.tocolor;
        end

        dxDrawRectangle(x + 6 + (columns * 44), y + 40 + (rows * 44), 40, 40, color);
        if (playerItems[i] and itemImages[playerItems[i].itemid]) then 
            local alpha = (moveItem and moveItem.from == i) and tocolor(255, 255, 255, 100) or tocolor(255, 255, 255, 255);
            dxDrawImage(x + 6 + (columns * 44) + 1, y + 40 + (rows * 44) + 1, 38, 38, itemImages[playerItems[i].itemid], 0, 0, 0, alpha);
            dxDrawText(playerItems[i].count, x + 6 + (columns * 44) + 40 / 2, y + 60 + (rows * 44) + 40 / 2, _, _, _, 1, core:getFont('opensans', 8), 'center', 'center');
        end

        columns = columns + 1;
    end

    --[[ Plusz cuccok rendere (sisak, golyóálló mellény, stb...) (33-36 slotig) ]]--
    local index = 0;
    for i = 33, 36 do 
        --[[ Háttere ]]--
        local color = colors.grey2.tocolor;
        if (core:cursorInZone(x + px - 44, y + 40 + (index * 44), 40, 40)) then 
            color = colors.server.tocolor;
        end

        dxDrawRectangle(x + px - 47, y + 40 + (index * 44), 40, 40, color);

        index = index + 1;
    end

    --[[ Mozgatás közben a kurzornál legyen az item ]]--
    if (moveItem ~= nil) then
        local cx, cy = getCursorPosition();
        cx, cy = sx*cx, sy*cy;
        dxDrawImage(cx - 38 / 2, cy - 38 / 2, 38, 38, itemImages[moveItem.item], 0, 0, 0, _, true);
    end

    --[[ Súly számolás ]]--
    dxDrawRectangle(x, y + py - 3, px, 3, colors.server.tocolor);
    dxDrawText('2 / 25 kg', x + px / 2, y + py - 5, _, _, _, 1, core:getFont('opensans', 10), 'center', 'bottom');

    --dxDrawText(inspect(getElementData(localPlayer, 'character >> inventory')), 20, sy / 2, _, _, _, 1, 'arial', _, 'center');
    dxDrawText(inspect(moveItem), 60, sy / 2, _, _, _, 1, 'arial', _, 'center');
end

function clickInventory(button, state)
    if (not getElementData(localPlayer, 'logged') or isPedDead(localPlayer)) then closeInventory(); return; end

    local playerItems = getElementData(localPlayer, 'character >> inventory') or {};
    if (not playerItems) then return; end
    if (button == 'left' and state == 'down') then 
        local columns = 0;
        local rows = 0;
        for i = 1, 32 do 
            if (columns >= 8) then 
                columns = 0;
                rows = rows + 1;
            end

            if (core:cursorInZone(x + 6 + (columns * 44), y + 40 + (rows * 44), 40, 40)) then 
                if (storageItemSlot and storageItemSlot == i) then return; end

                if (playerItems[i] and itemImages[playerItems[i].itemid]) then 
                    moveItem = { from = i, item = playerItems[i].itemid };
                    return;
                end
            end

            columns = columns + 1;
        end
    elseif (button == 'left' and state == 'up') then 
        if (moveItem ~= nil) then 
            local columns = 0;
            local rows = 0;
            for i = 1, 32 do 
                if (columns >= 8) then 
                    columns = 0;
                    rows = rows + 1;
                end

                if (core:cursorInZone(x + 6 + (columns * 44), y + 40 + (rows * 44), 40, 40)) then 
                    if (moveItem and moveItem.from == i) then moveItem = nil; return; end
                    if (playerItems[i] == nil) then 
                        triggerServerEvent('inventory:moveItem', localPlayer, localPlayer, i, moveItem);
                        moveItem = nil;
                        return;
                    else
                        if (items[playerItems[i].itemid] and (items[playerItems[i].itemid].stackable or false) and items[moveItem.item] and items[moveItem.item].stackable and moveItem.item == playerItems[i].itemid) then -- Két ugyan olyan item ami stackelhető, mennyiség összeadása
                            triggerServerEvent('inventory:stackItem', localPlayer, localPlayer, i, moveItem);
                            moveItem = nil;
                            return;
                        elseif (items[playerItems[i].itemid].storage) then 
                            if (not items[playerItems[i].itemid].storage.allowedItems or tableHasValue(items[playerItems[i].itemid].storage.allowedItems, moveItem.item)) then 
                                if (not items[playerItems[i].itemid].storage.disallowedItems or not tableHasValue(items[playerItems[i].itemid].storage.disallowedItems, moveItem.item)) then 
                                    if (countEmptyStorageSlots(playerItems[i].data.items, items[playerItems[i].itemid].storage.slots) > 0) then 
                                        local emptyslot = findFirstEmptyStorageSlot(playerItems[i].data.items, items[playerItems[i].itemid].storage.slots);
                                        if (emptyslot) then -- Van hely a storage itemben
                                            triggerServerEvent('inventory:putItemInStorage', localPlayer, localPlayer, playerItems[i], moveItem, i);
                                            moveItem = nil;
                                            return;
                                        else 
                                        end
                                    else 
                                        print('NINCS HELY!');
                                    end
                                else 
                                    print('Ezt a tárgyat nem lehet belerakni ebbe a tároló itembe! 2');
                                end
                            else 
                                print('Ezt a tárgyat nem lehet belerakni ebbe a tároló itembe! 1');
                            end
                        else
                            print('nemtom')
                            moveItem = nil;
                            return;
                        end
                    end
                end

                columns = columns + 1;
            end

            --Storagera húzás
            if (renderStorage and storageItemSlot) then
                local row = 0;
                local column = 0;
                for i = 1, items[playerItems[storageItemSlot].itemid].storage.slots do 
                    if (column >= 6) then 
                        row = row + 1;
                        column = 0;
                    end

                    if (core:cursorInZone(x + 3 + (column * 43), y + py + 8 + (row * 43), 40, 40)) then
                        if (not playerItems[storageItemSlot].data.items[i]) then 
                            if (not items[playerItems[storageItemSlot].itemid].storage.allowedItems or tableHasValue(items[playerItems[storageItemSlot].itemid].storage.allowedItems, moveItem.item)) then 
                                if (not items[playerItems[storageItemSlot].itemid].storage.disallowedItems or not tableHasValue(items[playerItems[storageItemSlot].itemid].storage.disallowedItems, moveItem.item)) then 
                                    triggerServerEvent('inventory:putItemInStorage', localPlayer, localPlayer, playerItems[storageItemSlot], moveItem, i, storageItemSlot);
                                end
                            end
                        end
                        moveItem = nil;
                        return;
                    end

                    column = column + 1;
                end
            end 

            if (moveItem ~= nil) then 
                moveItem = nil;
                return;
            end
        end
    elseif (button == 'right' and state == 'down') then 

    elseif (button == 'right' and state == 'up') then 
        local columns = 0;
        local rows = 0;
        for i = 1, 32 do 
            if (columns >= 8) then 
                columns = 0;
                rows = rows + 1;
            end

            if (core:cursorInZone(x + 6 + (columns * 44), y + 40 + (rows * 44), 40, 40)) then 
                triggerServerEvent('inventory:use', localPlayer, localPlayer, i);
                return;
            end

            columns = columns + 1;
        end
    end
end

function closeInventory()
    removeEventHandler('onClientRender', root, renderInventory);
    removeEventHandler('onClientClick', root, clickInventory);
    render = false;
end

--[[ Storage cucc ]]-- 

addEvent('inventory:openStorage', true);
addEventHandler('inventory:openStorage', root, function(slot)
    if (not renderStorage) then 
        local inventory = getElementData(localPlayer, 'character >> inventory');
        if (inventory[slot] and isStorageItem(inventory[slot].itemid) and render) then 
            storageItemSlot = slot;
            renderStorage = true;
            addEventHandler('onClientRender', root, renderStoragePanel);
            addEventHandler('onClientClick', root, clickStoragePanel);
        end
    else 
        removeEventHandler('onClientRender', root, renderStoragePanel);
        removeEventHandler('onClientClick', root, clickStoragePanel);
        renderStorage = false;
        storageItemSlot = nil;
    end
end);

function renderStoragePanel()
    if (not render or not renderStorage or not storageItemSlot or not getElementData(localPlayer, 'character >> inventory')[storageItemSlot].data.items) then
        removeEventHandler('onClientRender', root, renderStoragePanel);
        removeEventHandler('onClientClick', root, clickStoragePanel);
        renderStorage = false;
        storageItemSlot = nil;
    end

    local sinventory = getElementData(localPlayer, 'character >> inventory');
    local storage = sinventory[storageItemSlot].data.items;

    dxDrawRectangle(x, y + py + 5, 260, 1 + ((math.floor(items[sinventory[storageItemSlot].itemid].storage.slots / 6)) * 44), colors.grey1.tocolor);

    dxDrawText(inspect(storage), 10, sy / 2, _, _, _, 1, 'arial', 'left', 'center')

    local column = 0;
    local row = 0;
    for i = 1, items[sinventory[storageItemSlot].itemid].storage.slots do 
        if (column >= 6) then 
            row = row + 1;
            column = 0;
        end

        local color = colors.grey2.tocolor;
        if (core:cursorInZone(x + 3 + (column * 43), y + py + 8 + (row * 43), 40, 40)) then 
            color = colors.server.tocolor;
        end

        dxDrawRectangle(x + 3 + (column * 43), y + py + 8 + (row * 43), 40, 40, color, false);

        if (storage[i]) then 
            local alpha = (storageMoveItem and storageMoveItem.from == i) and tocolor(255, 255, 255, 100) or tocolor(255, 255, 255, 255);
            dxDrawImage(x + 4 + (column * 43), y + py + 9 + (row * 43), 38, 38, itemImages[storage[i].itemid]);
            dxDrawText(storage[i].count, x + 4 + (column * 43) + 38, y + py + 9 + (row * 43) + 38, _, _, _, 1, core:getFont('opensans', 8), 'right', 'bottom');
        end

        if (storageMoveItem ~= nil) then
            local cx, cy = getCursorPosition();
            cx, cy = sx*cx, sy*cy;
            dxDrawImage(cx - 38 / 2, cy - 38 / 2, 42, 42, itemImages[storageMoveItem.item], 0, 0, 0, _, true);
        end

        column = column + 1;
    end
end

function clickStoragePanel(button, state)
    local sinventory = getElementData(localPlayer, 'character >> inventory');
    local storage = sinventory[storageItemSlot].data.items;

    if (button == 'left' and state == 'down') then 
        local column = 0;
        local row = 0;
        for i = 1, items[sinventory[storageItemSlot].itemid].storage.slots do 
            if (column >= 6) then 
                row = row + 1;
                column = 0;
            end

            if (core:cursorInZone(x + 3 + (column * 43), y + py + 8 + (row * 43), 40, 40)) then 
                if (storage[i]) then 
                    storageMoveItem = {from = i, item = storage[i].itemid};
                end
                return;
            end

            column = column + 1;
        end
    elseif (button == 'left' and state == 'up') then 
        if (storageMoveItem) then 
            -- Storage itemen belüli mozgatás
            local column = 0;
            local row = 0;
            for i = 1, items[sinventory[storageItemSlot].itemid].storage.slots do -- Storagen belüli mozgatás
                if (column >= 6) then 
                    row = row + 1;
                    column = 0;
                end
    
                if (core:cursorInZone(x + 3 + (column * 43), y + py + 8 + (row * 43), 40, 40)) then 
                    if (not storage[i]) then -- Ha nincs azon a sloton semmi
                        triggerServerEvent('inventory:moveItemInsideStorage', localPlayer, localPlayer, storageMoveItem, storageItemSlot, i);
                    else 

                    end

                    storageMoveItem = nil;
                    return;
                end
    
                column = column + 1;
            end

            -- Itembe visszahúzás
            local column = 0;
            local row = 0;
            for i = 1, 32 do 
                if (column >= 8) then 
                    column = 0;
                    row = row + 1;
                end

                if (core:cursorInZone(x + 6 + (column * 44), y + 40 + (row * 44), 40, 40)) then 
                    if (sinventory[i] == nil) then 
                        print('NINCS')
                        triggerServerEvent('inventory:moveItemOutsideStorage', localPlayer, localPlayer, storageMoveItem, storageItemSlot, i);
                        storageMoveItem = nil;
                    else 
                        if (sinventory[i].itemid and storage[storageMoveItem.from].itemid and sinventory[i].itemid == storage[storageMoveItem.from].itemid) then 
                            triggerServerEvent('inventory:stackItemOutsideStorage', localPlayer, localPlayer, storageMoveItem, storageItemSlot, i);
                        end

                        storageMoveItem = nil;
                    end

                    --[[if (moveItem and moveItem.from == i) then moveItem = nil; return; end
                    if (playerItems[i] == nil) then 
                        print('HÚZÁS')
                        triggerServerEvent('inventory:moveItem', localPlayer, localPlayer, i, moveItem);
                        moveItem = nil;
                        return;
                    else
                        if (items[playerItems[i].itemid] and (items[playerItems[i].itemid].stackable or false) and items[moveItem.item] and items[moveItem.item].stackable and moveItem.item == playerItems[i].itemid) then -- Két ugyan olyan item ami stackelhető, mennyiség összeadása
                            triggerServerEvent('inventory:stackItem', localPlayer, localPlayer, i, moveItem);
                            moveItem = nil;
                            return;
                        elseif (items[playerItems[i].itemid].storage) then 
                            if (not items[playerItems[i].itemid].storage.allowedItems or tableHasValue(items[playerItems[i].itemid].storage.allowedItems, moveItem.item)) then 
                                if (not items[playerItems[i].itemid].storage.disallowedItems or not tableHasValue(items[playerItems[i].itemid].storage.disallowedItems, moveItem.item)) then 
                                    if (countEmptyStorageSlots(playerItems[i].data.items, items[playerItems[i].itemid].storage.slots) > 0) then 
                                        local emptyslot = findFirstEmptyStorageSlot(playerItems[i].data.items, items[playerItems[i].itemid].storage.slots);
                                        if (emptyslot) then -- Van hely a storage itemben
                                            triggerServerEvent('inventory:putItemInStorage', localPlayer, localPlayer, playerItems[i], moveItem, i);
                                            moveItem = nil;
                                            return;
                                        else 
                                        end
                                    else 
                                        print('NINCS HELY!');
                                    end
                                else 
                                    print('Ezt a tárgyat nem lehet belerakni ebbe a tároló itembe! 2');
                                end
                            else 
                                print('Ezt a tárgyat nem lehet belerakni ebbe a tároló itembe! 1');
                            end
                        else
                            print('nemtom')
                            moveItem = nil;
                            return;
                        end
                    end]]
                end

                column = column + 1;
            end
        end
    end
end

--[[ Minden féle szar függvény ]]--

function findFirstEmptySlot()
    local inventory = getElementData(localPlayer, 'character >> inventory') or {};
    local columns = 0;
    local rows = 0;
    for i = 1, 32 do 
        if (columns >= 8) then 
            columns = 0;
            rows = rows + 1;
        end

        if (core:cursorInZone(x + 6 + (columns * 44), y + 40 + (rows * 44), 40, 40)) then 
            if (inventory[i] == nil) then 
                return i;
            end
        end

        columns = columns + 1;
    end

    return false;
end

--[[ Actionbar cucc ]]--

local actionbar = {
    x = sx / 2 - 285 / 2,
    y = 20,
};

addEventHandler('onClientRender', root, function()
    if (not getElementData(localPlayer, 'logged')) then return; end
    dxDrawRectangle(actionbar.x, actionbar.y, 285, 50, colors.grey1.tocolor, true);
    for i = 0, 5 do 
        local color = colors.grey2.tocolor;
        if (core:cursorInZone(actionbar.x + 3 + (i * 47), actionbar.y + 3, 44, 44)) then 
            color = colors.server.tocolor;
        end

        dxDrawRectangle(actionbar.x + 3 + (i * 47), actionbar.y + 3, 44, 44, color, true);
        dxDrawText(i + 1, actionbar.x + 3 + (i * 47) + 44 / 2, actionbar.y + 3 + 44 / 2, _, _, tocolor(255, 255, 255, 25), 1, core:getFont('opensansbold', 13), 'center', 'center', _, _, true);
    end
end);

interface:addInterfaceElement('actionbar', sx / 2 - 285, sy - 55, 285, 50, 285, 285, 50, 50, false);

triggerEvent('interface:forceUpdate', root, 'actionbar');
addEventHandler('interface:update', root, function(element, x, y, w, h)
    if (element == 'actionbar') then 
        actionbar.x = x;
        actionbar.y = y;
    end
end);

function cursorInZone(x, y, w, h)
    if (not isCursorShowing()) then return false; end
    local cx, cy = getCursorPosition();
    cx, cy = cx*sx, cy*sy;
    return (cx > x and cx < x + w and cy > y and cy < y + h and true or false);
end