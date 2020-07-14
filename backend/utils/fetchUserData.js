const db = require('../db');

const fetchUserData = async function(id, role){
    const data = await db.query('select ws.authenticate_person($1, $2)', [id, role]);
    const user = data.rows[0].authenticate_person;
    return user;
}

module.exports = fetchUserData;