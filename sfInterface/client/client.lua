core = exports['sfCore'];
colors = core:getAllColors();

local sx, sy = guiGetScreenSize();

local font = core:getFont('fa', 10);

local action = false;
local moving = false;
local panels = {};
local edit = true;

function addInterfaceElement(name, x, y, w, h, minw, maxw, minh, maxh, sizeable)
    if (not panels[name]) then 
        panels[name] = { 
            x = x, y = y, 
            w = w, h = h, 
            minw = minw, minh = minh,
            maxw = maxw, maxh = maxh,
            offx = 0, offy = 0,
            sizeable = sizeable,
        };
    end
end

addEventHandler('onClientRender', root, function()
    if (not isCursorShowing()) then return; end
    if (getKeyState('lctrl')) then edit = true; else edit = false; end
    if (edit) then 
        for i,v in pairs(panels) do 

            dxDrawText((moving or 'moving') .. ' - ' .. (action or 'action'), 500, 20);

            if (isCursorShowing() and moving and moving == i and action and action == 'move') then 
                local cx, cy = getCursorPosition();
                cx = cx * sx;
				cy = cy * sy;
				v.x = cx - v.offx;
                v.y = cy - v.offy;
                triggerEvent('interface:update', root, moving, v.x, v.y, v.w, v.h);
            end

            if (isCursorShowing() and moving and moving == i and action and action == 'scale') then 
                local cx, cy = getCursorPosition();
                cx, cy = sx*cx, sy*cy;
                local sizex = cx - v.x;
                local sizey = cy - v.y;

                if (sizex < v.minw or sizex > v.maxw) then 
                    if (sizex < v.minw) then v.w = v.minw; end
                    if (sizex > v.maxw) then v.w = v.maxw; end
                else 
                    v.w = sizex;
                end

                if (sizey < v.minh or sizey > v.maxh) then 
                    if (sizey < v.minh) then v.h = v.minh; end
                    if (sizey > v.maxh) then v.h = v.maxh; end
                else 
                    v.h = sizey;
                end

                triggerEvent('interface:update', root, moving, v.x, v.y, v.w, v.h);
            end

            dxDrawRectangle(v.x - 3, v.y - 3, v.w + 6, v.h + 6, tocolor(colors.server.rgb[1], colors.server.rgb[2], colors.server.rgb[3], 100));

            if (v.sizeable) then 
                dxDrawText('', v.x - 2 + v.w, v.y - 2 + v.h, v.x - 3 + v.w + 6, v.y - 3 + v.h + 6, tocolor(0, 0, 0), 1, font, 'center', 'center', _, _, true);
                dxDrawText('', v.x - 3 + v.w, v.y - 3 + v.h, v.x - 3 + v.w + 6, v.y - 3 + v.h + 6, colors.white.tocolor, 1, font, 'center', 'center', _, _, true);
            end
        end
    end
end);

addEventHandler('onClientClick', root, function(button, state, cx, cy)
    if (isCursorShowing() and button == 'left') then 
        if (state == 'down') then 
            for i,v in pairs(panels) do 
                if (core:cursorInZone(v.x - 8 + v.w, v.y - 8 + v.h, 16, 16) and v.sizeable) then -- hosszúság méretezés
                    action = 'scale';
                    moving = i;
                    break;
                elseif (core:cursorInZone(v.x - 8, v.y - 8, v.w + 16, v.h + 16)) then -- mozgatás
                    action = 'move';
                    moving = i;
                    v.offx = cx - v.x;
                    v.offy = cy - v.y;
                    break;
                end 
            end
        else 
            saveInterface();
            moving = false;
            action = false;
        end
    end
end);

function saveInterface()
    local file = xmlLoadFile('client/save.xml');
    if (not file) then 
        file = xmlCreateFile('client/save.xml', 'interface');

        for i,v in pairs(panels) do 
            local node = xmlCreateChild(file, i);
            xmlNodeSetValue(xmlCreateChild(node, 'x'), v.x);
            xmlNodeSetValue(xmlCreateChild(node, 'y'), v.y);
            xmlNodeSetValue(xmlCreateChild(node, 'w'), v.w);
            xmlNodeSetValue(xmlCreateChild(node, 'h'), v.h);
        end
    else 
        for i,v in pairs(panels) do 
            local node = xmlFindChild(file, i, 0);
            xmlNodeSetValue(xmlFindChild(node, 'x', 0), v.x);
            xmlNodeSetValue(xmlFindChild(node, 'y', 0), v.y);
            xmlNodeSetValue(xmlFindChild(node, 'w', 0), v.w);
            xmlNodeSetValue(xmlFindChild(node, 'h', 0), v.h);
        end
    end

    xmlSaveFile(file);
    xmlUnloadFile(file);
end

function loadInterface()
    local file = xmlLoadFile('client/save.xml');
    if (file) then
        for i,v in pairs(panels) do 
            local node = xmlFindChild(file, i, 0);
            local x = xmlNodeGetValue(xmlFindChild(node, 'x', 0));
            local y = xmlNodeGetValue(xmlFindChild(node, 'y', 0));
            local w = xmlNodeGetValue(xmlFindChild(node, 'w', 0));
            local h = xmlNodeGetValue(xmlFindChild(node, 'h', 0));

            triggerEvent('interface:update', root, i, x, y, w, h);

            panels[i].x = x;
            panels[i].y = y;
            panels[i].w = w;
            panels[i].h = h;
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    setTimer(function()
        loadInterface();
    end, 1000, 1);
end);

addEventHandler('interface:forceUpdate', root, function(element)
    print('force1');
    if (panels[element]) then 
        print('force2');
        local v = panels[element];
        triggerEvent('interface:update', root, element, v.x, v.y, v.w, v.h);
    end
end);

addEvent('interface:forceUpdate'); --[[ Küldje ki a pozíciókat ]]--
addEvent('interface:update'); --[[ Ha mozgatják ]]--
addEvent('interface:show'); --[[ Ha előzozzák az eltűntetett interface listából ]]--
addEvent('interface:hide'); --[[ Ha eltűntetik ]]--
addEvent('interface:reset'); --[[ Ha resetelik a pozícióját, minden szarját ]]--