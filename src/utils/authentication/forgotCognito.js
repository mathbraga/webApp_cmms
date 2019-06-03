import { UserPoolId, ClientId } from "../../aws";

var AmazonCognitoIdentity = require("amazon-cognito-identity-js");

export default function forgotCognito(email){
  return new Promise((resolve, reject) => {
    let userPool = new AmazonCognitoIdentity.CognitoUserPool({
      UserPoolId: UserPoolId,
      ClientId: ClientId
    });
  
    let cognitoUser = new AmazonCognitoIdentity.CognitoUser({
      Username: email,
      Pool: userPool
    });
  
    cognitoUser.forgotPassword({
      onSuccess: function (data) {
        console.log('CodeDeliveryData from forgotPassword: ' + data);
        resolve(true);
      },
      onFailure: function(err) {
        console.log(err.message || JSON.stringify(err));
        resolve(false);
      }
      // ,
      //Optional automatic callback
      // inputVerificationCode: function(data) {
      //   console.log('Code sent to: ' + data);
      //   var code = document.getElementById('code').value;
      //   var newPassword = document.getElementById('new_password').value;
      //   cognitoUser.confirmPassword(verificationCode, newPassword, {
      //       onSuccess() {
      //           console.log('Password confirmed!');
      //       },
      //       onFailure(err) {
      //           console.log('Password not confirmed!');
      //       }
      //   });
      // }
    });
  });
}