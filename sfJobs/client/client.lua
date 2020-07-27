local sx, sy = guiGetScreenSize();
local px, py = unpack(config.panels.main.size);
local x, y = sx/2-px/2, sy/2-py/2;
local colors = config.colors;
local fonts = config.fonts;

local jobs = {};
local selectedJob = 'bus';

local jobRow = 0;
local jobMax = 8;

local render;

addEventHandler('onClientClick', root, function(button, state, _, _, _, _, _, entity)
    if (button == 'left' and state == 'up') then 
        if (not render and isElement(entity) and getElementData(entity, 'job >> ped')) then 
            render = true;

            addEventHandler('onClientRender', root, renderPanel);
            bindKey('mouse_wheel_down', 'down', scrollDownPanel);
            bindKey('mouse_wheel_up', 'down', scrollUpPanel);
        end
    end
end);

function renderPanel()
    dxDrawRectangle(x, y, px, py, colors.background.tocolor);
    
    -- Render job list
    local index = 0;
    for i,v in pairs(jobs) do 
        local color = colors.darkgrey.tocolor;
        if (selectedJob == i) then 
            color = colors.main.tocolor;
        end

        dxDrawRectangle(x + 3, y + 3 + (index * 38), px / 2.5, 35, color);
        dxDrawText(v.title, x + 6, y + 6 + (index * 38), x + 6 + px / 2.5 - 12, y + 6 + (index * 38) + 29, tocolor(255, 255, 255), 1, fonts.opensansbold, 'left', 'center');

        index = index + 1;
    end
    dxDrawScrollbar(x + 3 + px / 2.5 + 3, y + 3, 12, py - 42, colors.darkgrey.tocolor, colors.main.tocolor, 2, jobRow, jobMax, index);


    if (selectedJob) then 
        local data = jobs[selectedJob];

        -- Job title
        dxDrawText(data.title, x + 6 + px / 2.5 + 16, y + 6, _, _, _, 1, fonts.opensansbold16, 'left');
        dxDrawRectangle(x + 6 + px / 2.5 + 16, y + 35, dxGetTextWidth(data.title, 1, fonts.opensansbold16) + 16, 3, colors.main.tocolor);

        -- Job description
        dxDrawText('Munka leírása', x + 6 + px / 2.5 + 16, y + 55, _, _, _, 1, fonts.opensansbold, 'left');
        dxDrawRectangle(x + 6 + px / 2.5 + 16, y + 75, dxGetTextWidth('Munka leírása', 1, fonts.opensansbold) + 8, 2, colors.main.tocolor);
        dxDrawText(data.data.description, x + 6 + px / 2.5 + 16, y + 90, x + 6 + px / 2.5 + 16 + px * 0.55, y + 225, _, 1, fonts.opensans10, 'left', 'top', true, true);

        -- Others
        dxDrawText('Munka specifikációi', x + 6 + px / 2.5 + 16, y + 240, _, _, _, 1, fonts.opensansbold, 'left');
        dxDrawRectangle(x + 6 + px / 2.5 + 16, y + 260, dxGetTextWidth('Munka specifikációi', 1, fonts.opensansbold) + 8, 2, colors.main.tocolor);
        local index = 0;
        for i,v in pairs(data.data.others) do 
            dxDrawText(v.index .. ': ' .. colors.main.hex .. v.value, x + 6 + px / 2.5 + 16, y + 270 + (index * 20), _, _, _, 1, fonts.opensans, _, _, _, _, _, true);

            index = index + 1;
        end
    end

    --dxDrawText(inspect(jobs), 3, sy / 2, _, _, _, 1, 'arial', 'left', 'center');
end

function scrollUpPanel()
    if (jobRow > 0) then 
        jobRow = jobRow - 1;
    end
end

function scrollDownPanel()
    if (jobRow < jobMax) then 
        jobRow = jobRow + 1;
    end
end

-- Sync jobs from server
addEvent('jobs:syncJobsToClient', true);
addEventHandler('jobs:syncJobsToClient', root, function(table)
    print('sync')
    jobs = table;
end);

-- Require jobs from server on client start
addEventHandler('onClientResourceStart', resourceRoot, function()
    triggerServerEvent('jobs:requireJobs', resourceRoot);
end);

-- Toggle job ped damage
addEventHandler('onClientPedDamage', root, function()
    if (getElementData(source, 'job >> ped')) then 
        cancelEvent();
    end
end);

addEventHandler('onClientPlayerStealthKill', root, function()
    if (getElementData(source, 'job >> ped')) then 
        cancelEvent();
    end
end);