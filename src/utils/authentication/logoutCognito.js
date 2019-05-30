var AmazonCognitoIdentity = require("amazon-cognito-identity-js");

export default function logoutCognito(userSession){
  return new Promise((resolve, reject) => {

    // console.clear();
    // console.log('inside logoutCognito');
    
    let userPool = new AmazonCognitoIdentity.CognitoUserPool({
      UserPoolId : "us-east-2_QljBw37l1",
      ClientId : "25k8mc8m13pgpaihrhvcuvonpq"
    });

    let cognitoUser = new AmazonCognitoIdentity.CognitoUser({
      Username: userSession.getIdToken().payload.email,
      Pool: userPool
    });

    cognitoUser.signOut();
    // window.sessionStorage.clear();
    // console.log(window.sessionStorage);
    resolve();
  });
}