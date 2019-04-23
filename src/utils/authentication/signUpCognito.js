import AWS from "aws-sdk";
import {
  CognitoUserPool,
  CognitoUserAttribute
} from "amazon-cognito-identity-js";

export default function loginCognito(email, password1, password2){
  
  console.clear();
  console.log('inside signUpCognito');
  
  if(password1 === password2){
    AWS.config.region = 'us-east-2';
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
      IdentityPoolId : 'us-east-2:a92ff2fa-ce00-47d1-b72f-5e3ee87fa955',
    });

    let poolData = {
      UserPoolId : "us-east-2_QljBw37l1",
      ClientId : "25k8mc8m13pgpaihrhvcuvonpq"
    };

    let userPool = new CognitoUserPool(poolData);

    const attributeList = [
      new CognitoUserAttribute({
        Name: 'email',
        Value: email,
      })
    ];
      
    userPool.signUp(email, password1, attributeList, null, (err, result) => {
      if (err) {
        console.log(err);
        alert("Falha no cadastro.\n\nInsira novamente as infomações.\n\nSe o problema persistir, contate o administrador.")
        return;
        }
      console.log('user name is ' + result.user.getUsername());
      console.log('call result: ' + result);
    });
  } else {
    alert("Falha no cadastro.\n\nInsira novamente as infomações.\n\nSe o problema persistir, contate o administrador.");
  }
}