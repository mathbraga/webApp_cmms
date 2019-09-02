export default function login(email, password){
  return new Promise((resolve, reject) => {
    
    fetch(process.env.REACT_APP_SERVER_URL + '/login', {
      method: 'POST',
      credentials: 'include',
      body: JSON.stringify({
        email: email,
        password: password
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    })
      .then(r => r.json())
      .then(rjson => {
        console.log(rjson);
        resolve();
      })
      .catch(error => {
        console.log(error);
        reject("Erro no login.")
      });
  });
}