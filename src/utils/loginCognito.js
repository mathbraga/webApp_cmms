import AWS from "aws-sdk";

export default function loginCognito(){
  // let authenticationData = {
  //   Username : this.state.username,
  //   Password : this.state.password
  // };
  
  // let authenticationDetails = new AWS.AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
  
  // let cognitoUser = new AmazonCognitoIdentity.CognitoUser({
  //   Username: this.state.username,
  //   Pool: this.state.userPool
  // });
  
  // cognitoUser.authenticateUser(authenticationDetails, {
  //   onSuccess: function (result) {
  //       var accessToken = result.getAccessToken().getJwtToken();
  //   },
  
  //   onFailure: function(err) {
  //       alert(err);
  //   }
  //   // mfaRequired: function(codeDeliveryDetails) {
  //   //     var verificationCode = prompt('Please input verification code' ,'');
  //   //     cognitoUser.sendMFACode(verificationCode, this);
  //   // }
  // });
  
  // AWS.config.credentials = new AWS.CognitoIdentityCredentials({
  //   IdentityPoolId: "",
  //   Logins: {
  //       "": result.getIdToken().getJwtToken()
  //   }
  // });
  
  // AWS.config.credentials.get(function(err){
  //   if (err) {
  //       alert(err);
  //   }
  // });
}

