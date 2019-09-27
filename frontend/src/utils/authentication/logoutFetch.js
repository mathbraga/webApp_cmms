export default function logoutFetch(){
  return new Promise((resolve, reject) => {
    
    fetch(process.env.REACT_APP_SERVER_URL + '/auth/logout', {
      method: 'GET',
      credentials: 'include',
    })
      .then(r => r.json())
      .then(rjson => {
        console.log(rjson);
        resolve();
      })
      .catch(error => {
        console.log(error);
        reject("Erro no logout.")
      });
  });
}