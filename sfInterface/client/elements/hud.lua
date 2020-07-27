local sx, sy = guiGetScreenSize();

local font1 = core:getFont('fa', 10);
local font2 = core:getFont('opensansbold', 20);

local lastTimeTick = getTickCount();
local lastTime = '00:00';

local hudElements = {
    healthbar = {
        position = {
            x = sx - 204,
            y = 20, 
            width = 200,
            height = 16,
        },
        default = {
            x = sx - 304,
            y = 20, 
            width = 204,
            height = 16,
        },
        limits = {
            width = { min = 100, max = 300 },
            height = { min = 10, max = 35 },
        },
        data = {
            type = 'bar',
            func = getElementHealth,
            args = {localPlayer},
            color = colors.red.tocolor,
            icon = '',
            sizeable = true,
        },
    },
    hungerbar = {
        position = {
            x = sx - 204,
            y = 42, 
            width = 200,
            height = 16,
        },
        default = {
            x = sx - 304,
            y = 20, 
            width = 204,
            height = 16,
        },
        limits = {
            width = { min = 100, max = 300 },
            height = { min = 10, max = 35 },
        },
        data = {
            type = 'bar',
            func = getElementData,
            args = {localPlayer, 'character >> hunger'},
            color = tocolor(122, 51, 15),
            icon = '',
            sizeable = true,
        },
    },
    thirstbar = {
        position = {
            x = sx - 204,
            y = 64, 
            width = 200,
            height = 16,
        },
        default = {
            x = sx - 304,
            y = 20, 
            width = 204,
            height = 16,
        },
        limits = {
            width = { min = 100, max = 300 },
            height = { min = 10, max = 35 },
        },
        data = {
            type = 'bar',
            func = getElementData,
            args = {localPlayer, 'character >> thirst'},
            color = colors.blue.tocolor,
            icon = '',
            sizeable = true,
        },
    },
    money = {
        position = {
            x = sx - 104,
            y = 95, 
            width = 100,
            height = 24,
        },
        default = {
            x = sx - 104,
            y = 95, 
            width = 100,
            height = 24,
        },
        limits = {
            width = { min = 100, max = 300 },
            height = { min = 24, max = 24 },
        },
        data = {
            alignx = 'right',
            aligny = 'center',
            type = 'text',
            func = getElementData,
            args = {localPlayer, 'character >> money'},
            color = tocolor(255, 255, 255),
            sizeable = true,
        },
    },
    time = {
        position = {
            x = sx - 225,
            y = 95, 
            width = 73,
            height = 24,
        },
        default = {
            x = sx - 225,
            y = 95, 
            width = 73,
            height = 24,
        },
        limits = {
            width = { min = 73, max = 73 },
            height = { min = 24, max = 24 },
        },
        data = {
            alignx = 'center',
            aligny = 'center',
            type = 'text',
            func = function() 
                if (lastTimeTick + 2000 > getTickCount()) then return lastTime; end 
                lastTimeTick = getTickCount();
                local time = getRealTime();
                local hours = time.hour;
                local minutes = (time.minute >= 10 and time.minute or '0'..time.minute);
                lastTime = hours..':'..minutes;
                return lastTime;
            end,
            args = {},
            color = tocolor(255, 255, 255),
            sizeable = false,
        },
    },
};

addEventHandler('onClientResourceStart', resourceRoot, function()
    for name, val in pairs(hudElements) do 
        addInterfaceElement(name, val.position.x, val.position.y, val.position.width, val.position.height, val.limits.width.min, val.limits.width.max, val.limits.height.min, val.limits.height.max, (val.data.sizeable));
    end
end);

addEventHandler('onClientRender', root, function()
    if (not getElementData(localPlayer, 'logged') or isPedDead(localPlayer)) then return; end

    for i,v in pairs(hudElements) do 
        if (v.data.type == 'bar') then 
            dxDrawSegmentBar(v.position.x, v.position.y, v.position.width, v.position.height, colors.grey1.tocolor, v.data.color, v.data.func(unpack(v.data.args)), 3, 2, 4);
            dxDrawText(v.data.icon, v.position.x - 12 + 1, v.position.y + v.position.height / 2 + 1, _, _, tocolor(0, 0, 0), 1, font1, 'center', 'center');
            dxDrawText(v.data.icon, v.position.x - 12, v.position.y + v.position.height / 2, _, _, v.data.color, 1, font1, 'center', 'center');
            --dxDrawSegmentBar(v.position.x + 2, v.position.y + 2, v.position.width - 4, v.position.height - 4, colors.red.tocolor);
        elseif (v.data.type == 'text') then 
            local text = formatNumber(v.data.func(unpack(v.data.args)));
            
            if (i == 'money') then 
                dxDrawText('$', v.position.x + 1, v.position.y + 1, v.position.x + v.position.width, v.position.y + v.position.height, tocolor(0, 0, 0), 1, font2, v.data.alignx, v.data.aligny, true, false);
                dxDrawText('$', v.position.x, v.position.y, v.position.x + v.position.width, v.position.y + v.position.height, v.data.color, 1, font2, v.data.alignx, v.data.aligny, true, false, _, true);
                dxDrawText(text, v.position.x + 1, v.position.y + 1, v.position.x + v.position.width - 15, v.position.y + v.position.height, tocolor(0, 0, 0), 1, font2, v.data.alignx, v.data.aligny, true, false);
                dxDrawText(text, v.position.x, v.position.y, v.position.x + v.position.width - 15, v.position.y + v.position.height, tocolor(50, 168, 82), 1, font2, v.data.alignx, v.data.aligny, true, false);
            else
                dxDrawText(text, v.position.x + 1, v.position.y + 1, v.position.x + v.position.width - 0, v.position.y + v.position.height, tocolor(0, 0, 0), 1, font2, v.data.alignx, v.data.aligny, true, false);
                dxDrawText(text, v.position.x, v.position.y, v.position.x + v.position.width - 0, v.position.y + v.position.height, v.data.color, 1, font2, v.data.alignx, v.data.aligny, true, false);
            end
        end
    end
end);

addEventHandler('interface:update', root, function(element, x, y, w, h)
    if (hudElements[element]) then 
        hudElements[element].position.x = x;
        hudElements[element].position.y = y;
        hudElements[element].position.width = w;
        hudElements[element].position.height = h;
    end
end);

function dxDrawSegmentBar(startX, startY, width, height, backgroundColor, progressColor, currentValue, gapWidth, inner, numOfSegments, postGUI, subPixelPositioning)
    inner = inner or 0
    backgroundColor = backgroundColor or tocolor(0, 0, 0, 200)
    progressColor = progressColor or tocolor(0, 150, 255)

    currentValue = currentValue and math.min(100, currentValue) or 0
    gapWidth = gapWidth or 5
    numOfSegments = numOfSegments or 3

    local widthWithGap = width - gapWidth * (numOfSegments - 1)
    local oneSegmentWidth = widthWithGap / numOfSegments - inner / 2

    local progressPerSegment = 100 / numOfSegments
    local remainingProgress = currentValue % progressPerSegment

    local segmentsFull = math.floor(currentValue / progressPerSegment)
    local segmentsInUse = math.ceil(currentValue / progressPerSegment)

    for i = 1, numOfSegments do
        local segmentX = startX + (oneSegmentWidth + gapWidth) * (i - 1)

        dxDrawRectangle(segmentX, startY, oneSegmentWidth, height, backgroundColor, postGUI, subPixelPositioning)

        if i <= segmentsFull then
            dxDrawRectangle(segmentX + inner, startY + inner, oneSegmentWidth - inner * 2, height - inner * 2, progressColor, postGUI, subPixelPositioning)
        elseif i == segmentsInUse then
            if remainingProgress > 0 then
                dxDrawRectangle(segmentX + inner, startY + inner, oneSegmentWidth / progressPerSegment * remainingProgress - inner * 2, height - inner * 2, progressColor, postGUI, subPixelPositioning)
            end
        end
    end
end

function formatNumber(number) 
	while true do      
		number, k = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1,%2')    
		if k==0 then      
			break   
		end  
	end  
	return number
end

function time()
    local time = getRealTime();
    local hours = time.hour;
    local minutes = (time.minute >= 10 and time.minute or '0'..time.minute);
    return hours..':'..minutes;
end