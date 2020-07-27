local dbData = {
    host = 'mysql.serverstack.hu',
    username = 'u31_1lktY41VdU',
    password = 'LA^8F!TQsf.rAmvPPYbnn+I4',
    database = 's31_sfrp'
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
