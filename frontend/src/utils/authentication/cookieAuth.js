export default function cookieAuth(){
    return new Promise((resolve, reject) => {
      
      fetch(process.env.REACT_APP_SERVER_URL + '/authcookie', {
        method: 'GET',
        credentials: 'include'
      })
        .then(r => {
          if(r.status === 200){
            resolve(r.json());
          } 
          else if(r.status === 400){
            throw new Error('Cookie not found!');
            // reject();
          }
        })
        .catch(error => {
          reject(error);
        });
    });
  }