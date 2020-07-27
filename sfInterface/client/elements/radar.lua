local sx, sy = guiGetScreenSize();

local font = core:getFont('opensansbold', 12);

local settings = {
    show = true,
    position = {
        x = 10,
        y = sy - 200,
        w = 300,
        h = 195,
    },
    default = {
        x = 10,
        y = sy - 200,
        w = 300,
        h = 195,
    },
    limits = {
        width = { min = 250, max = 500 },
        height = { min = 150, max = 450 },
    },
    texture = dxCreateTexture('client/elements/assets/images/map.png'),
    target = dxCreateRenderTarget(350, 200, true),
};

local blipTextures = {};
local imageWidth, imageHeight = dxGetMaterialSize(settings.texture);
local zoom = 1;

addInterfaceElement('radar', settings.position.x, settings.position.y, settings.position.w, settings.position.h, settings.limits.width.min, settings.limits.width.max, settings.limits.height.min, settings.limits.height.max, true);

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i= 0, 50 do 
        if fileExists("client/elements/assets/blips/"..i..".png") then 
            blipTextures[i] = dxCreateTexture("client/elements/assets/blips/"..i..".png", "dxt3", true);
        end
    end
end);

addEventHandler('onClientPreRender', root, function()
    if (not getElementData(localPlayer, 'logged') or isPedDead(localPlayer)) then return; end

    if (settings.show) then
        local _, _, camZ = getElementRotation(getCamera());
        local px, py, pz = getElementPosition(localPlayer);

        local mw, mh = dxGetMaterialSize(settings.target);
        if (settings.position.w ~= mw or settings.position.h ~= mh) then 
            destroyElement(settings.target);
            settings.target = dxCreateRenderTarget(settings.position.w, settings.position.h, true);
        end

        if (getKeyState('num_add')) then 
            if (zoom < 4) then 
                zoom = zoom + 0.04;
            end
        elseif (getKeyState('num_sub')) then 
            if (zoom > 0.5) then 
                zoom = zoom - 0.04;
            end
        end

        dxSetRenderTarget(settings.target, true);
		local mW, mH = dxGetMaterialSize(settings.target);
		local ex, ey = mW / 2 - px / (6000 / (imageWidth * zoom)), mH / 2 + py / (6000 / (imageHeight * zoom));
		dxDrawRectangle(0,0, mW, mH, tocolor(128, 166, 205));
		dxDrawImage(ex - (imageWidth * zoom)/2, (ey - (imageHeight * zoom)/2), (imageWidth * zoom), (imageHeight * zoom), settings.texture, camZ, (px/(6000/(imageWidth * zoom))), -(py/(6000/(imageHeight * zoom))), tocolor(255, 255, 255, 255));
        dxSetRenderTarget();
        
        dxDrawRectangle(settings.position.x, settings.position.y, settings.position.w, settings.position.h, colors.grey1.tocolor);
        dxDrawText(getZoneName(px, py, pz), settings.position.x + 5, settings.position.y + settings.position.h, (settings.position.x + 5) + settings.position.w, settings.position.y + (settings.position.h - 36), tocolor(255, 255, 255), 1, font, 'left', 'center');
        dxDrawImage(settings.position.x + 2, settings.position.y + 2, settings.position.w - 4, settings.position.h - 36, settings.target, 0, 0, 0, tocolor(255,255,255), false);
        dxDrawImage((settings.position.x + 2) + (settings.position.w - 4) / 2 - 24 / 2, (settings.position.y + 2) + (settings.position.h - 36) / 2 - 24 / 2, 24, 24, 'client/elements/assets/images/arrow.png', camZ-getPedRotation(localPlayer));
    end
end);

addEventHandler('interface:update', root, function(element, x, y, w, h)
    if (element == 'radar') then 
        settings.position.x = x;
        settings.position.y = y;
        settings.position.w = w;
        settings.position.h = h;
    end
end);

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end;
	return t;
end