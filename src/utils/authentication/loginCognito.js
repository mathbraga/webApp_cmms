var AmazonCognitoIdentity = require('amazon-cognito-identity-js');

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
    onSuccess: function (result) {
        var accessToken = result.getAccessToken().getJwtToken();
        console.log("Access token:");
        console.log(accessToken);
        alert("Login efetuado com sucesso.\nUsuário logado: " + email);
    },
    onFailure: function(err) {
        console.log("Login falhou.");
        alert(err.message || JSON.stringify(err));
    },
  });
}