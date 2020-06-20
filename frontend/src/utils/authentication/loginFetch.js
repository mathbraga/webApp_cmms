import React, { Component } from "react";
import { render } from "../../../../backend/app";

// class loginFetch extends Component{
//   constructor(props){
//     super(props);
//     this.state = {}
//   }

//   login = (email, password) => {

//   }

//   render(){
    
//   }
// }

export default function loginFetch(email, password){
  return new Promise((resolve, reject) => {
    
    fetch(process.env.REACT_APP_SERVER_URL + process.env.REACT_APP_LOGIN_PATH, {
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
          return r.json();
        } else {
          reject();
        }
      })
      .then(r => {
        console.log(r);
      })
      .catch(error => {
        alert(error);
        reject("Erro no login.")
      });
  });
}