local dbData = {
    host = '',
    username = '',
    password = '',
    database = ''
};

local connection;

addEventHandler('onResourceStart', resourceRoot, function()
    connection = dbConnect('mysql', 'dbname='..dbData.database..';host='..dbData.host..';charset=utf8', dbData.username, dbData.password);
    if (not connection) then 
        print('Sikertelen adatbázis csatlakozás..');
        cancelEvent();
    else 
        print('Sikeres adatbázis csatlakozás!');
    end
end);

function getConnection()
    return connection;
end
