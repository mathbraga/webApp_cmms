const db = require('../db');

async (email, password) => {
    let data;
    try {
      data = await db.query('select api.authenticate($1, $2)', [email, password]);
      if (data.rows.length === 0) {
        throw new Error('User not found.');
      }
    } catch (error) {
      return error;
    }
    
    let userID = data.rows[0].authenticate.split(" - ");
    const token = jwt.sign({userId: userID, email: email}, 'testkey');

    return token;
  }