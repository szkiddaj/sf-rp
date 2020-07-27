local camera = {
    position = { start = {}, stop = {} },
    point = { start = {}, stop = {} },
};

local enabled = true;
local active = false;
local current = 0;
local camTime = 1000;
local tick = getTickCount();

function smoothCameraMove(pos1, pos2, point1, point2, time)
    if (not enabled) then return false; end
    tick = getTickCount();
    current = 0;
    camTime = time or 1000;

    camera.position.start = pos1;
    camera.position.stop = pos2;
    camera.point.start = point1;
    camera.point.stop = point2;

    if (not active) then 
        active = true;
        addEventHandler('onClientPreRender', root, renderCamera);
    end
end

function renderCamera()
    if (not enabled) then return false; end
    local now = getTickCount();
    local px, py, pz = interpolateBetween(camera.position.start[1], camera.position.start[2], camera.position.start[3], camera.position.stop[1], camera.position.stop[2], camera.position.stop[3], (now - tick) / camTime, 'InOutQuad');
    local cx, cy, cz = interpolateBetween(camera.point.start[1], camera.point.start[2], camera.point.start[3], camera.point.stop[1], camera.point.stop[2], camera.point.stop[3], (now - tick) / camTime, 'InOutQuad');
    setCameraMatrix(px, py, pz, cx, cy, cz);

    if ((now - tick) / camTime > 1) then 
        removeEventHandler('onClientPreRender', root, renderCamera);
        active = false;
    end
end

function setCameraState(state)
    enabled = state;
    print(tostring(enabled));
end