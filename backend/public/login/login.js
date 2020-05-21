function loginData(){
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    loginFetch(email, password).then(console.log("login successful."));
}

function loginFetch(email, password){
    return new Promise((resolve, reject) => {
      
      fetch("http://localhost:3001" + "/auth/login", {
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