export default function logoutFetch(){
  return new Promise((resolve, reject) => {
    
    fetch(process.env.REACT_APP_SERVER_URL + process.env.REACT_APP_LOGOUT_PATH, {
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