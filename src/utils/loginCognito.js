// import * as AWS from 'aws-sdk/global';
var AmazonCognitoIdentity = require('amazon-cognito-identity-js');


export default function loginCognito(username, password){
  
  console.clear();
  console.log('inside loginCognito');
  
  let authenticationData = {
    Username : username,
    Password : password
  };
  
  let authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
  
  let poolData = {
    UserPoolId : "us-east-2_QljBw37l1",
    ClientId : "25k8mc8m13pgpaihrhvcuvonpq"
  };

  let userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

  let cognitoUser = new AmazonCognitoIdentity.CognitoUser({
    Username: username,
    Pool: userPool
  });

  cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: function (result) {
        var accessToken = result.getAccessToken().getJwtToken();
        console.log("Access token:");
        console.log(accessToken);

        //POTENTIAL: Region needs to be set if not already set previously elsewhere.
        // AWS.config.region = 'us-east-2';

        // AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        //     IdentityPoolId : 'us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955', // your identity pool id here
        //     Logins : {
        //         // Change the key below according to the specific region your user pool is in.
        //         'cognito-idp.us-east-2.amazonaws.com/us-east-2_b0jTWet7h' : result.getIdToken().getJwtToken()
        //     }
        // });
        //
        //refreshes credentials using AWS.CognitoIdentity.getCredentialsForIdentity()
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
        alert(err.message || JSON.stringify(err));
    },

});

}