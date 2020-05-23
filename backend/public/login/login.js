function loginData(){
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    loginFetch(email, password);
}

function loginFetch(email, password){
    return new Promise((resolve, reject) => {
      
      fetch(process.env.REACT_APP_SERVER_URL + process.env.REACT_APP_LOGIN_PATH, { //se um .env.local não existir REACT_APP_SERVER_URL=http://172.23.22.152:3001
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
        .then(r => {
          if(r.status === 200){
            resolve();
          } else {
            reject();
          }
        })
        .catch(error => {
          alert(error);
          reject("Erro no login.")
        });
    });
}