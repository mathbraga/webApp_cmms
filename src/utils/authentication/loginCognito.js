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
        console.log(result); // result = CognioUserSession
        var accessToken = result.getAccessToken().getJwtToken();
        console.log("Access token:");
        console.log(accessToken);
        alert("Login efetuado com sucesso.\n\nUsuário logado: " + email);
        window.sessionStorage.setItem("accessToken", accessToken);
        console.log(window);



        // 1) adicionar funções do package jose (usar token com segurança)


        // 2) inicializar uma credential do AWS (identity pool com role que tenha uma policy adequada ao usuário logado)
        // segue abaixo um exemplo de como fazer isso:




        // //POTENTIAL: Region needs to be set if not already set previously elsewhere.
        // AWS.config.region = '<region>';

        // AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        //     IdentityPoolId : '...', // your identity pool id here
        //     Logins : {
        //         // Change the key below according to the specific region your user pool is in.
        //         'cognito-idp.<region>.amazonaws.com/<YOUR_USER_POOL_ID>' : result.getIdToken().getJwtToken()
        //     }
        // });

        // //refreshes credentials using AWS.CognitoIdentity.getCredentialsForIdentity()
        // AWS.config.credentials.refresh((error) => {
        //     if (error) {
        //          console.error(error);
        //     } else {
        //          // Instantiate aws sdk service objects now that the credentials have been updated.
        //          // example: var s3 = new AWS.S3();
        //          console.log('Successfully logged!');
        //     }
        // });






    },
    onFailure: function(err) {
        console.log("Login falhou.");
        alert(err.message || JSON.stringify(err));
    },
  });
}