connection = false;

addEventHandler('onResourceStart', resourceRoot,
    function()
        if connection then
            destroyElement(connection);
        end

        local host = ('dbname=%s;host=%s'):format(DATABASE.dbname, DATABASE.host)

        connection = dbConnect('mysql', host, DATABASE.username, DATABASE.password, 'share=1')

        if connection then
            outputDebugString('Core >> Successful database connection.', 0, 159, 226, 191)
        else
            outputDebugString('Core >> Error connecting to database.', 0, 255, 70, 64)
        end
    end
);

function getDatabaseConnection()
    return connection or false;
end