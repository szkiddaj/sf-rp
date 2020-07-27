function findFirstEmptyStorageSlot(items, slotCount)
    for i = 1, slotCount do 
        if (items[i] == nil) then 
            return i;
        end 
    end
    return false;
end

function countEmptyStorageSlots(storage, slotCount)
    local count = 0;
    for i = 1, slotCount do 
        if (storage[i] == nil) then 
            count = count + 1;
        end 
    end
    return count;
end

function tableHasValue(table, item)
    for i = 1, #table do 
        if (table[i] == item) then 
            return true;
        end 
    end
    return false;
end