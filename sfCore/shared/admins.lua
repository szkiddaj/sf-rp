local titles = {'Adminsegéd', 'Admin', 'FőAdmin', 'Tulajdonos', 'Vezérfejlesztő'};

function getAdminTitle(level)
    return (titles[tonumber(level)] and titles[tonumber(level)] or 'Ismeretlen');
end 

function getAdminTitles()
    return titles;
end