local core = exports['sfCore'];
local colors = core:getAllColors();

local maxClients = core:getServerData('maxslot');

local font = core:getFont('opensans', 12);
local font2 = core:getFont('opensansbold', 12);
local font3 = core:getFont('fa', 13);
local font4 = core:getFont('opensansbold', 15);

local sx, sy = guiGetScreenSize();
local px, py = 350, 442;
local x, y = sx/2-px/2, sy/2-py/2;

local maxRow = 12;
local currRow = 0;

local render = false;

local players = {};

addEventHandler('onClientKey', root, function(key, press)
    if (key == 'tab') then 
        if (press) then 
            if (not getElementData(localPlayer, 'logged')) then return; end
            render = true;
            addEventHandler('onClientRender', root, renderScoreboard);
            bindKey('mouse_wheel_up', 'down', scrollUp);
            bindKey('mouse_wheel_down', 'down', scrollDown);

            reloadPlayers();
        else 
            render = false;
            removeEventHandler('onClientRender', root, renderScoreboard);
            unbindKey('mouse_wheel_up', 'down', scrollUp);
            unbindKey('mouse_wheel_down', 'down', scrollDown);
        end
    end
end);

function renderScoreboard()
    if (not getElementData(localPlayer, 'logged')) then 
        render = false;
        removeEventHandler('onClientRender', root, renderScoreboard);
        unbindKey('mouse_wheel_up', 'down', scrollUp);
        unbindKey('mouse_wheel_down', 'down', scrollDown);
        return;
    end 

    dxDrawRectangle(x, y, px, py, colors.grey1.tocolor);

    dxDrawText('', x + px - 3, y, x + px - 6, y + 34, _, 1, font3, 'right', 'center');
    dxDrawText(#players - 3, x + px - 3, y, x + px - 38, y + 34, colors.server.tocolor, 1, font4, 'right', 'center');

    dxDrawText('San Fierro'..colors.white.hex..' Roleplay', x + 4, y, x + px - 8, y + 34, colors.server.tocolor, 1, font2, 'left', 'center', _, _, _, true);
    local index = 0;
    for i, value in ipairs(players) do 
        if (i > currRow and index < maxRow) then 
            index = index + 1;
            local color = colors.grey2.tocolor;
            if (not value.id) then 
                color = colors.server.tocolor;

                dxDrawGradientRectangle(x + 2 , y + (index * 34), px - 20, 32, {224, 104, 34}, {224, 123, 34});
                dxDrawText(value, x + 8, y + (index * 34), x + 6 + (px - 20), y + (index * 34) + 32, _, 1, font, 'left', 'center');
            else 
                local admin = (value.admin and colors.server.hex..' ('..value.admin..')' or '');
                dxDrawRectangle(x + 2 , y + (index * 34), px - 4, 32, color);
                dxDrawText(value.id, x + 6, y + (index * 34), x + 6 + (px - 24), y + 32 + (index * 34), colors.white.tocolor, 1, font, 'left', 'center');
                dxDrawText(value.name .. admin, x, y + (index * 34), x + px - 24, y + (index * 34) + 32, colors.white.tocolor, 1, font, 'center', 'center', _, _, _, true);
                dxDrawText(getPlayerPing(value.player) .. '#ffffff ms', x + 6, y + (index * 34), x + px - 24, y + (index * 34) + 32, colors.server.tocolor, 1, font, 'right', 'center', _, _, _, true);
            end
        end
    end

    drawScrollbar(x + px - 16, y + 36, 14, py - 39, colors.grey3.tocolor, colors.server.tocolor, currRow, maxRow, #players - 3, py - 39);
end

function reloadPlayers()
    players = {};

    table.insert(players, 'Adminisztrátorok');

    for _, player in ipairs(getElementsByType('player')) do 
        if (getElementData(player, 'admin >> duty') and getElementData(player, 'logged')) then 
            print(core:getAdminTitle(getElementData(player, 'admin >> level')))
            table.insert(players, {
                id = getElementData(player, 'player >> id'),
                name = getElementData(player, 'admin >> name'),
                admin = core:getAdminTitle(getElementData(player, 'admin >> level')),
                player = player,
            });
        end
    end

    table.insert(players, 'Játékos');

    for i, player in ipairs(getElementsByType('player')) do 
        if (not getElementData(player, 'admin >> duty') and getElementData(player, 'logged')) then 
            table.insert(players, {
                id = getElementData(player, 'player >> id'),
                name = getElementData(player, 'character >> name'),
                player = player,
            });
        end
    end

    table.insert(players, 'Bejelentkezés alatt');

    for _, player in ipairs(getElementsByType('player')) do 
        if (not getElementData(player, 'logged')) then 
            table.insert(players, {
                id = getElementData(player, 'player >> id'),
                name = getPlayerName(player),
                player = player,
            });
        end
    end
end

function scrollUp()
    if (currRow > 0) then 
        currRow = currRow - 1;
    end
end 

function scrollDown()
    if (currRow < #players - maxRow) then 
        currRow = currRow + 1;
    end
end

function dxDrawGradientRectangle(x, y, w, h, color1, color2) --[[ Nem tudom máshogy megoldani, bocs xd ]]
    local count = 0;
    while (count < w) do
        local width = (((x + (count * 1) + 10) < x + px) and 10 or (x + px) - (x + (count * 1) + 4));
        if (width ~= 10) then 
            dxDrawText(width, 500, 20);
        end
        local r, g, b = interpolateBetween(color1[1], color1[2], color1[3], color2[1], color2[2], color2[3], count / w, 'Linear');
        dxDrawRectangle(x + (count * 1), y, width, h, tocolor(r, g, b));
        count = count + 10;
    end
end

function RandomVariable(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function drawScrollbar(x, y, w, h, bgcolor, color, index, lines, count)
    local visible = math.min(lines / count, 1.0);
    visible = math.max(visible, 0.05);
    local height = (h - 4) * visible;
    local position = math.min(index / count, 1.0 - visible) * (h - 4);
    dxDrawRectangle(x, y, w, h, bgcolor, true);
    dxDrawRectangle(x + 2, y + 2 + position, w - 4, height, color, true);
end