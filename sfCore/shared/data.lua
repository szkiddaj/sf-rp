data = {
    servername = 'San Fierro Roleplay',
    shortname = 'SFRP',
    version = '0.0.1',
    debug = true,

    gametype = 'SF-RP ALPHA',
    mapname = 'San Fierro',
    owner = 'Lacipaci',
    developers = 'szkiddaj & Danihe',
    maxslot = 10,
    fps = 63,
};

colors = {
    server = { hex = '#e06822', rgb = {224, 104, 34}, tocolor = tocolor(224, 104, 34) },
    red = { hex = '#b03131', rgb = {176, 49, 49}, tocolor = tocolor(176, 49, 49) },
    green = { hex = '#35b53d', rgb = {53, 181, 61}, tocolor = tocolor(53, 181, 61) },
    blue = { hex = '#398fc4', rgb = {57, 143, 196}, tocolor = tocolor(57, 143, 196) },
    grey1 = { hex = '#0e0e0e', rgb = {14, 14, 14}, tocolor = tocolor(14, 14, 14) },
    grey2 = { hex = '#121212', rgb = {18, 18, 18}, tocolor = tocolor(18, 18, 18) },
    grey3 = { hex = '#181818', rgb = {24, 24, 24}, tocolor = tocolor(24, 24, 24) },
    white = { hex = '#ffffff', rgb = {255, 255, 255}, tocolor = tocolor(255, 255, 255) },
};

function getServerData(dataname)
    return (data[dataname] or false);
end

function getColor(color, type)
    if (not colors[color]) then return false end;
    return colors[color][type];
end

function getColors(color) --[[ Visszaadja a colors ]]
    if (not colors[color]) then return false end;
    return colors[color];
end

function getAllColors() --[[ Visszaadja az egész colors táblát ]]
    return colors;
end

function getServerSyntax(extra, text) --[[ [Szervernév - 'extra']: 'text' ]]
    if (extra and text) then return (colors.server.hex .. '[' .. data.shortname .. ' - ' .. extra .. ']: ' .. colors.white.hex .. text) end;
    if (not extra and text) then return (colors.server.hex .. '[' .. data.shortname .. ']: ' .. colors.white.hex .. text) end;
    if (not extra and not text) then return (colors.server.hex .. '[' .. data.shortname .. ']: ' .. colors.server.hex) end;
end
