export default function cookieAuth(){
    return new Promise((resolve, reject) => {
      
      fetch(process.env.REACT_APP_SERVER_URL + '/', {
        method: 'GET',
        credentials: 'include'
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