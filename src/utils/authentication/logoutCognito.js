var AmazonCognitoIdentity = require("amazon-cognito-identity-js");

export default function logoutCognito(email){
  return new Promise((resolve, reject) => {

    console.clear();
    console.log('inside logoutCognito');
    
    let userPool = new AmazonCognitoIdentity.CognitoUserPool({
      UserPoolId : "us-east-2_QljBw37l1",
      ClientId : "25k8mc8m13pgpaihrhvcuvonpq"
    });

    let cognitoUser = new AmazonCognitoIdentity.CognitoUser({
      Username: email,
      Pool: userPool
    });

    cognitoUser.signOut();
    window.sessionStorage.clear();
    resolve();
  });
}