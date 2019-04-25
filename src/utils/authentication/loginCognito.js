import AWS from "aws-sdk";
var AmazonCognitoIdentity = require("amazon-cognito-identity-js");

export default function loginCognito(email, password){
  
  console.clear();
  console.log('inside loginCognito');
  
  let authenticationData = {
    Username : email,
    Password : password
  };
  
  let authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
  
  let poolData = {
    UserPoolId : "us-east-2_QljBw37l1",
    ClientId : "25k8mc8m13pgpaihrhvcuvonpq"
  };

  let userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

  let cognitoUser = new AmazonCognitoIdentity.CognitoUser({
    Username: email,
    Pool: userPool
  });

  cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: function (userSession) {
      
      console.log("Login efetuado com sucesso.\n\nUsuário logado: " + email);
      
      console.log("userSession:");
      console.log(userSession);
      // var accessToken = userSession.getAccessToken().getJwtToken();
      // console.log("Access token:");
      // console.log(accessToken);
      // alert("Login efetuado com sucesso.\n\nUsuário logado: " + email);
      
      // 1) TODO: add JOSE package functions to encrypt token


      // 2) Initialize AWS credential with a role that has auth user permissions
      AWS.config.region = "us-east-2";
      AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: "us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955",
        Logins: {
            "cognito-idp.us-east-2.amazonaws.com/us-east-2_QljBw37l1": userSession.getIdToken().getJwtToken()
        }
      });

      console.log(AWS.config);

      let dynamo = new AWS.DynamoDB({
        apiVersion: "2012-08-10",
        endpoint: "https://dynamodb.us-east-2.amazonaws.com"
      });

      console.log(dynamo);

      window.sessionStorage.setItem("dynamo", dynamo);


      // refreshes credentials using AWS.CognitoIdentity.getCredentialsForIdentity()
      // AWS.config.credentials.refresh((error) => {
      //     if (error) {
      //          console.error(error);
      //     } else {
      //       // Instantiate aws sdk service objects now that the credentials have been updated.
      //       // example: var s3 = new AWS.S3();
      //       let dynamo = new AWS.DynamoDB({
      //         apiVersion: "2012-08-10",
      //         endpoint: "https://dynamodb.us-east-2.amazonaws.com"
      //       });
      //       window.sessionStorage.setItem("dynamo", dynamo);
      //     }
      // });
    },
    onFailure: function(err) {
        console.log("Login falhou.");
        alert(err.message || JSON.stringify(err));
    },
  });
}